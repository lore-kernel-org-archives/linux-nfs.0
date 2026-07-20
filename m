Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A27C03264DC;
	Mon, 20 Jul 2026 14:28:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784557703; cv=none; b=JYJdlfVBiAdsXBLD/iteRd8eCwhGMA3rDBqw6oTqyCDoZy4EgHQVrQadqclkdtMM2TNubOVh/mTC9jqXTcOkUvDpfbWQXWvkiimhhrIx5MrOuZdWUWaUZGjTcPMgBSCVVc3MwuGzoLUqbf5G/hCSXxigm1et9tbVQoUy4R4R2aM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784557703; c=relaxed/simple;
	bh=g2zVGvSMZfRtNEx+YAO4eIysu1VnCao/znR3mj/0yVA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=G2AFdxAQZxd0y+s3jTM+wReEeD27bzPRmOQdv2F3BtVbANnFxSpi9KmSh3nLh+qH54AgZwwxRrkOCGc09RinB2lkujbY4jQr9N++dxwV6lt6Kj8lK9uWa+ah412wmY8ogjlfjcJ44u9d+LLn7o+OwcuC8puZWyHbVSzYdTBENWQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JETpELUn; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JETpELUn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1CAD61F000E9;
	Mon, 20 Jul 2026 14:28:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784557699;
	bh=hkeXKQHqEh8W/3Jslh1IH7jQ/5yWgQMENRQPRm5cmys=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JETpELUnHseGp3pMwWwMqOT6Wv+lYqzxh78mpdTchFiGPo56hm/pthgev+TCr9s+g
	 f3s4B3vfp42OMTE9z4OT+qNHmr39NsRtZrrKQklb7EoHXfHh9vpknRn7CKTiRe4nSh
	 ov11refLrufS4Gy1H0GFlId9lfklT26xLUW/gWmDyFv5r207onTmEVHirGj8Tmvayq
	 dyQYjl8i2iPwYjuiseFmM49y4IqBtURJhuHIrMdMX6YIUaqbNoKPamXvdZvM3q8kK+
	 U7QXAfyFHVBchrFE6sw2tlTsawSBYy6BsizabB1hmaIQPSxaeTHRBygw330AGiugWf
	 tzeTyXRYQyQrQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 20 Jul 2026 10:27:58 -0400
Subject: [PATCH net-next v2 4/6] selftests/tls: Add tests for data/control
 record interleaving
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260720-tcp-read-sock-v2-4-29545d034f3c@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
In-Reply-To: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
To: Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Shuah Khan <shuah@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Chuck Lever <cel@kernel.org>
Cc: netdev@vger.kernel.org, kernel-tls-handshake@lists.linux.dev, 
 linux-kselftest@vger.kernel.org, linux-nfs@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=12612; i=cel@kernel.org;
 h=from:subject:message-id; bh=D0SWawaZKH6j9i8rwCiEuwtge1j5gzQn4HhgbK6NzNo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqXjB89wG4I7n7t+a0Oo8gEND2CAy5MWEjzgZNn
 fyxXuvuH/aJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCal4wfAAKCRAzarMzb2Z/
 l1p2EACWNaS9SOkKNOHojRIG096K2IMOyegDjT/+5LvfNRt3gLwQ2JQffhhri83SoscYSD0y/H9
 07lEJTJaD8+Q7gpDUEqeA+vMyZh0nhIVMhRQdVIO+TUHeqClMvYVUA6it++rYYormS3x4XMGik+
 UfUJZouN4YFVNbn2c5k3FAgOCRIUIulirB/6ZpY2+PuPpLgFgFNhz3brIFz5m3pkKPhFyu6hANw
 N2Oo8PQJwe7/Kq+xVfrTsmh5Wwyw54GGkB15GsqmF8oFayg/2T5833gbbrb91IH78uB242RJuPB
 BSy08mYchnCVjTrGuCAHCdHpQaYMGBHkTTR06nwLZBCnV2hmEHrpnGpXIVDX8pBZUDdQc/KTORo
 fJMvNq8KoRRGJZjIU+2k3KMNBL5C0HjhJywrAgIv3V0OhKnQ9ijFSySYpgW7ZieLNqxa2tgdKHb
 Polo21rvXOi+6e//KJyBHbbsjeQw02vmabV/BkCXkuwTFc/SlrwKUxBEkgmgUSyjWYwhCg+q8KX
 svda6mEGouwk6qVP0mzVKJfCKnxRsUHHt42+FAg+0lMvd286o7eoKB/h528G/njycDqy9yPEqMo
 oEWcAmT/3SU20u9qs3dIhYrt0Jf5blWUrrwCNSEpA4+C13RpBMeY+fY2n9hG1/u+bZUZZsjcK3O
 Y2srKCb7qsOiJEg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

The new read_sock_rectype proto_ops method delivers interleaved
data and control TLS records to kernel consumers through
separate callbacks. The existing selftest coverage for these
interleaving patterns is limited: data_control_data only
peeks, and splice_cmsg_to_pipe tests a single control record
in isolation.

Add seven tests that exercise the record patterns
read_sock_rectype is designed to handle:

- splice_data_cmsg_data: data-control-data via splice, with
  the control record drained through recvmsg between the two
  splice calls

- splice_multi_cmsg_data: data-control-control-data with
  distinct content types, verifying that each control record
  is independently drainable with its type preserved, and
  splice resumes afterward

- recv_data_cmsg_data: complete consumption of a
  data-control-data sequence through recv and recvmsg

- peek_cmsg_after_data: peek at an interleaved control
  record after the preceding data record has been consumed,
  then consume it

- cmsg_before_data: control record as the first record in the
  stream, followed by data

- mixed_control_types: two different control record types
  (distinct content_type values) interleaved with data,
  verifying type preservation through delivery

- data_cmsg_eof: trailing control record followed by
  connection close, verifying the receiver drains the
  control record and then observes EOF

The fixture teardown is also updated to skip closing fd
when a test has already closed it (as data_cmsg_eof does).

These tests exercise the record decryption and rx_list
delivery pipeline shared by the recvmsg, splice, and
read_sock paths. read_sock_rectype itself is a kernel-internal
API without a direct userspace entry point, so the tests
validate through the userspace-accessible paths.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 tools/testing/selftests/net/tls.c | 298 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 297 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/net/tls.c b/tools/testing/selftests/net/tls.c
index cbdd3ea28b99..8136306b5caa 100644
--- a/tools/testing/selftests/net/tls.c
+++ b/tools/testing/selftests/net/tls.c
@@ -427,7 +427,8 @@ FIXTURE_SETUP(tls)
 
 FIXTURE_TEARDOWN(tls)
 {
-	close(self->fd);
+	if (self->fd >= 0)
+		close(self->fd);
 	close(self->cfd);
 }
 
@@ -897,6 +898,114 @@ TEST_F(tls, splice_dec_cmsg_to_pipe)
 	EXPECT_EQ(memcmp(test_str, buf, send_len), 0);
 }
 
+/* Verify splice handles data-control-data: splice reads the data
+ * records successfully while the intervening control record must
+ * be drained via recvmsg before splice can continue.
+ */
+TEST_F(tls, splice_data_cmsg_data)
+{
+	char mem_send[TLS_PAYLOAD_MAX_LEN];
+	char mem_recv[TLS_PAYLOAD_MAX_LEN];
+	int send_len = 4096;
+	char *ctrl_str = "control";
+	int ctrl_len = strlen(ctrl_str) + 1;
+	char ctrl_buf[8];
+	int p[2];
+
+	if (self->notls)
+		SKIP(return, "no TLS support");
+
+	memrnd(mem_send, sizeof(mem_send));
+
+	ASSERT_GE(pipe(p), 0);
+
+	/* Send: data, control, data */
+	EXPECT_EQ(send(self->fd, mem_send, send_len, 0), send_len);
+	EXPECT_EQ(tls_send_cmsg(self->fd, 100, ctrl_str, ctrl_len, 0),
+		  ctrl_len);
+	EXPECT_EQ(send(self->fd, &mem_send[send_len], send_len, 0), send_len);
+
+	/* Splice first data record */
+	EXPECT_EQ(splice(self->cfd, NULL, p[1], NULL, send_len, 0), send_len);
+	EXPECT_EQ(read(p[0], mem_recv, send_len), send_len);
+	EXPECT_EQ(memcmp(mem_send, mem_recv, send_len), 0);
+
+	/* Splice hits control record, fails */
+	EXPECT_EQ(splice(self->cfd, NULL, p[1], NULL, send_len, 0), -1);
+	EXPECT_EQ(errno, EINVAL);
+
+	/* Drain the control record via recvmsg */
+	EXPECT_EQ(tls_recv_cmsg(_metadata, self->cfd, 100,
+				ctrl_buf, sizeof(ctrl_buf), MSG_WAITALL),
+		  ctrl_len);
+	EXPECT_EQ(memcmp(ctrl_str, ctrl_buf, ctrl_len), 0);
+
+	/* Splice second data record */
+	EXPECT_EQ(splice(self->cfd, NULL, p[1], NULL, send_len, 0), send_len);
+	EXPECT_EQ(read(p[0], mem_recv, send_len), send_len);
+	EXPECT_EQ(memcmp(&mem_send[send_len], mem_recv, send_len), 0);
+}
+
+/* Verify that multiple consecutive control records between data
+ * records can each be drained individually, and splice resumes
+ * afterward.  The two control records use different content types
+ * to verify type preservation across the splice boundary.
+ */
+TEST_F(tls, splice_multi_cmsg_data)
+{
+	char mem_send[TLS_PAYLOAD_MAX_LEN];
+	char mem_recv[TLS_PAYLOAD_MAX_LEN];
+	int send_len = 4096;
+	char *ctrl1 = "alert1";
+	char *ctrl2 = "alert2";
+	int ctrl_len = strlen(ctrl1) + 1;
+	char ctrl_buf[7];
+	int p[2];
+
+	if (self->notls)
+		SKIP(return, "no TLS support");
+
+	memrnd(mem_send, sizeof(mem_send));
+
+	ASSERT_GE(pipe(p), 0);
+
+	/* Send: data, control(100), control(200), data */
+	EXPECT_EQ(send(self->fd, mem_send, send_len, 0), send_len);
+	EXPECT_EQ(tls_send_cmsg(self->fd, 100, ctrl1, ctrl_len, 0), ctrl_len);
+	EXPECT_EQ(tls_send_cmsg(self->fd, 200, ctrl2, ctrl_len, 0), ctrl_len);
+	EXPECT_EQ(send(self->fd, &mem_send[send_len], send_len, 0), send_len);
+
+	/* Splice first data */
+	EXPECT_EQ(splice(self->cfd, NULL, p[1], NULL, send_len, 0), send_len);
+	EXPECT_EQ(read(p[0], mem_recv, send_len), send_len);
+	EXPECT_EQ(memcmp(mem_send, mem_recv, send_len), 0);
+
+	/* Splice fails on first control record */
+	EXPECT_EQ(splice(self->cfd, NULL, p[1], NULL, send_len, 0), -1);
+	EXPECT_EQ(errno, EINVAL);
+
+	/* Drain first control (type 100) */
+	EXPECT_EQ(tls_recv_cmsg(_metadata, self->cfd, 100,
+				ctrl_buf, sizeof(ctrl_buf), MSG_WAITALL),
+		  ctrl_len);
+	EXPECT_EQ(memcmp(ctrl1, ctrl_buf, ctrl_len), 0);
+
+	/* Splice fails on second control record */
+	EXPECT_EQ(splice(self->cfd, NULL, p[1], NULL, send_len, 0), -1);
+	EXPECT_EQ(errno, EINVAL);
+
+	/* Drain second control (type 200) */
+	EXPECT_EQ(tls_recv_cmsg(_metadata, self->cfd, 200,
+				ctrl_buf, sizeof(ctrl_buf), MSG_WAITALL),
+		  ctrl_len);
+	EXPECT_EQ(memcmp(ctrl2, ctrl_buf, ctrl_len), 0);
+
+	/* Splice second data */
+	EXPECT_EQ(splice(self->cfd, NULL, p[1], NULL, send_len, 0), send_len);
+	EXPECT_EQ(read(p[0], mem_recv, send_len), send_len);
+	EXPECT_EQ(memcmp(&mem_send[send_len], mem_recv, send_len), 0);
+}
+
 TEST_F(tls, recv_and_splice)
 {
 	int send_len = TLS_PAYLOAD_MAX_LEN;
@@ -1682,6 +1791,193 @@ TEST_F(tls, data_control_data)
 	EXPECT_EQ(recv(self->cfd, buf, sizeof(buf), MSG_PEEK), send_len);
 }
 
+/* Fully consume a data-control-data sequence.  The existing
+ * data_control_data test only peeks; this exercises complete
+ * record delivery through recv and recvmsg.
+ */
+TEST_F(tls, recv_data_cmsg_data)
+{
+	char *data1 = "first_data";
+	char *ctrl = "ctrl_msg";
+	char *data2 = "second_data";
+	int d1_len = strlen(data1) + 1;
+	int c_len = strlen(ctrl) + 1;
+	int d2_len = strlen(data2) + 1;
+	char buf[20];
+
+	if (self->notls)
+		SKIP(return, "no TLS support");
+
+	EXPECT_EQ(send(self->fd, data1, d1_len, 0), d1_len);
+	EXPECT_EQ(tls_send_cmsg(self->fd, 100, ctrl, c_len, 0), c_len);
+	EXPECT_EQ(send(self->fd, data2, d2_len, 0), d2_len);
+
+	/* First data record */
+	EXPECT_EQ(recv(self->cfd, buf, sizeof(buf), MSG_WAITALL), d1_len);
+	EXPECT_EQ(memcmp(buf, data1, d1_len), 0);
+
+	/* recv without cmsg buffer fails on control record */
+	EXPECT_EQ(recv(self->cfd, buf, sizeof(buf), 0), -1);
+	EXPECT_EQ(errno, EIO);
+
+	/* Drain control via recvmsg */
+	EXPECT_EQ(tls_recv_cmsg(_metadata, self->cfd, 100,
+				buf, sizeof(buf), MSG_WAITALL), c_len);
+	EXPECT_EQ(memcmp(buf, ctrl, c_len), 0);
+
+	/* Second data record */
+	EXPECT_EQ(recv(self->cfd, buf, d2_len, MSG_WAITALL), d2_len);
+	EXPECT_EQ(memcmp(buf, data2, d2_len), 0);
+}
+
+/* Peek at an interleaved control record after the preceding data
+ * record has been consumed, then consume it.  MSG_PEEK exposes the
+ * control record's type without consuming it.
+ */
+TEST_F(tls, peek_cmsg_after_data)
+{
+	char *data = "leading";
+	char *ctrl = "middle";
+	char *tail = "trailing";
+	int d_len = strlen(data) + 1;
+	int c_len = strlen(ctrl) + 1;
+	int t_len = strlen(tail) + 1;
+	char buf[20];
+
+	if (self->notls)
+		SKIP(return, "no TLS support");
+
+	EXPECT_EQ(send(self->fd, data, d_len, 0), d_len);
+	EXPECT_EQ(tls_send_cmsg(self->fd, 100, ctrl, c_len, 0), c_len);
+	EXPECT_EQ(send(self->fd, tail, t_len, 0), t_len);
+
+	/* Consume leading data */
+	EXPECT_EQ(recv(self->cfd, buf, sizeof(buf), MSG_WAITALL), d_len);
+	EXPECT_EQ(memcmp(buf, data, d_len), 0);
+
+	/* Peek at the control record */
+	EXPECT_EQ(tls_recv_cmsg(_metadata, self->cfd, 100,
+				buf, sizeof(buf), MSG_PEEK), c_len);
+	EXPECT_EQ(memcmp(buf, ctrl, c_len), 0);
+
+	/* Consume the control record */
+	EXPECT_EQ(tls_recv_cmsg(_metadata, self->cfd, 100,
+				buf, sizeof(buf), 0), c_len);
+	EXPECT_EQ(memcmp(buf, ctrl, c_len), 0);
+
+	/* Trailing data */
+	EXPECT_EQ(recv(self->cfd, buf, t_len, MSG_WAITALL), t_len);
+	EXPECT_EQ(memcmp(buf, tail, t_len), 0);
+}
+
+/* Control record as the first record in the stream, followed by
+ * data.  The control record must be drained before the data record
+ * becomes available.
+ */
+TEST_F(tls, cmsg_before_data)
+{
+	char *ctrl = "alert";
+	char *data = "payload";
+	int c_len = strlen(ctrl) + 1;
+	int d_len = strlen(data) + 1;
+	char buf[20];
+
+	if (self->notls)
+		SKIP(return, "no TLS support");
+
+	EXPECT_EQ(tls_send_cmsg(self->fd, 100, ctrl, c_len, 0), c_len);
+	EXPECT_EQ(send(self->fd, data, d_len, 0), d_len);
+
+	/* recv without cmsg fails */
+	EXPECT_EQ(recv(self->cfd, buf, sizeof(buf), 0), -1);
+	EXPECT_EQ(errno, EIO);
+
+	/* Drain control via recvmsg */
+	EXPECT_EQ(tls_recv_cmsg(_metadata, self->cfd, 100,
+				buf, sizeof(buf), MSG_WAITALL), c_len);
+	EXPECT_EQ(memcmp(buf, ctrl, c_len), 0);
+
+	/* Data follows */
+	EXPECT_EQ(recv(self->cfd, buf, d_len, MSG_WAITALL), d_len);
+	EXPECT_EQ(memcmp(buf, data, d_len), 0);
+}
+
+/* Two different control record types interleaved with data.
+ * Each control record is delivered with its own type preserved;
+ * verify both types arrive intact.
+ */
+TEST_F(tls, mixed_control_types)
+{
+	char *data1 = "data1";
+	char *ctrl1 = "handshake";
+	char *ctrl2 = "alert_msg";
+	char *data2 = "data2";
+	int d1_len = strlen(data1) + 1;
+	int c1_len = strlen(ctrl1) + 1;
+	int c2_len = strlen(ctrl2) + 1;
+	int d2_len = strlen(data2) + 1;
+	char buf[20];
+
+	if (self->notls)
+		SKIP(return, "no TLS support");
+
+	EXPECT_EQ(send(self->fd, data1, d1_len, 0), d1_len);
+	EXPECT_EQ(tls_send_cmsg(self->fd, 100, ctrl1, c1_len, 0), c1_len);
+	EXPECT_EQ(tls_send_cmsg(self->fd, 200, ctrl2, c2_len, 0), c2_len);
+	EXPECT_EQ(send(self->fd, data2, d2_len, 0), d2_len);
+
+	/* First data */
+	EXPECT_EQ(recv(self->cfd, buf, sizeof(buf), MSG_WAITALL), d1_len);
+	EXPECT_EQ(memcmp(buf, data1, d1_len), 0);
+
+	/* First control (type 100) */
+	EXPECT_EQ(tls_recv_cmsg(_metadata, self->cfd, 100,
+				buf, sizeof(buf), MSG_WAITALL), c1_len);
+	EXPECT_EQ(memcmp(buf, ctrl1, c1_len), 0);
+
+	/* Second control (type 200) */
+	EXPECT_EQ(tls_recv_cmsg(_metadata, self->cfd, 200,
+				buf, sizeof(buf), MSG_WAITALL), c2_len);
+	EXPECT_EQ(memcmp(buf, ctrl2, c2_len), 0);
+
+	/* Second data */
+	EXPECT_EQ(recv(self->cfd, buf, d2_len, MSG_WAITALL), d2_len);
+	EXPECT_EQ(memcmp(buf, data2, d2_len), 0);
+}
+
+/* Trailing control record with no data following it.  The sender
+ * closes the connection after the control record; the receiver
+ * drains the control and then observes EOF.
+ */
+TEST_F(tls, data_cmsg_eof)
+{
+	char *data = "payload";
+	char *ctrl = "final";
+	int d_len = strlen(data) + 1;
+	int c_len = strlen(ctrl) + 1;
+	char buf[20];
+
+	if (self->notls)
+		SKIP(return, "no TLS support");
+
+	EXPECT_EQ(send(self->fd, data, d_len, 0), d_len);
+	EXPECT_EQ(tls_send_cmsg(self->fd, 100, ctrl, c_len, 0), c_len);
+	EXPECT_EQ(close(self->fd), 0);
+	self->fd = -1;
+
+	/* Consume data */
+	EXPECT_EQ(recv(self->cfd, buf, sizeof(buf), MSG_WAITALL), d_len);
+	EXPECT_EQ(memcmp(buf, data, d_len), 0);
+
+	/* Drain trailing control */
+	EXPECT_EQ(tls_recv_cmsg(_metadata, self->cfd, 100,
+				buf, sizeof(buf), 0), c_len);
+	EXPECT_EQ(memcmp(buf, ctrl, c_len), 0);
+
+	/* Next recv returns EOF */
+	EXPECT_EQ(recv(self->cfd, buf, sizeof(buf), 0), 0);
+}
+
 TEST_F(tls, shutdown)
 {
 	char const *test_str = "test_read";

-- 
2.54.0

