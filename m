Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820377;
	b=vOgVdsoAX65kkxtA5sBsilBBKzvzBwhaupybT+RXa2F0woEm73gzPMeKgO7aotMzQNCQ
	 SY26q/HA2fGevXddX5VHZAPGoljxCJmLYySkqSDDSTntoyQElR/Avdv1adyPCISxwelIG
	 raZubTQ0gxgERLOuKw62KChoU19QOfbWJ1/UeCNOccpTlPva2FKp/tDltPnGH0B08rAf2
	 RBksm5FwqnrYcTACF+hLuVyHWJA7+gKCd5HWGyYcIpFuKaDvxTWTAVtjZ0PKCKG7aE0Ed
	 AJpHlkp9e5LKWkc/6OlmFrL9o1GMn4dY0oJP7CTPi17RD95SDI/zmItXuibGDS9DtxQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820377;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=XnpcpCSyDLdfO+af8k17UBoE0jHP5SM09VNPrTlP5mU=;
	b=fPQId6cNy9TeRmztXIeIGIHy+bwD5oKlDeG/330OC2FTAvNMoqnlLooJBBxucLPRQOW8
	 5Cho0Uu0PtVmafu3SrjBSxxXkZD/rQZ4x8yS/4gaXAgoF29iM52BIOrgMP7icfGzEKezR
	 ndMTrCOQdEaVhmD5E9ZgA6G4JJufUtyfMNgnGijv0jj5piBzSDGMJVwSpIErwsgzSglNm
	 zHZh+M6vv2bO2NvSe8Iv1u77Fr+z5CAZ3mfOTtlyAcqCFGIyfJXYClBFZ4fHek87khJ1I
	 tf1dZ/rNcqYrbB7GLv06L11woG+gt/6UCR2VBNXr3AKclNFr6tJH2gBpXHjaL6C5VVQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Fe+qeY3o;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA026606D812;
	Wed,  4 Nov 2026 19:26:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Fe+qeY3o
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 72DAD1F000C1;
	Wed,  4 Nov 2026 19:26:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820376;
	bh=XnpcpCSyDLdfO+af8k17UBoE0jHP5SM09VNPrTlP5mU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Fe+qeY3o8miJBk7XZvXWRPJiLnP1GdJPOqLtWaz6J/8VQem5/V0ND1YF0y/caRLDt
	 DgMyPqaYb8QP/iR50E51P8bLvmgXDHfJQAP+4NJ3uCNVkwg8J4gXwnwNVy6o82qXxc
	 G4M//wQeR0/W9Y+xsP86unflMsj2VnJzFCD6/c4qwO8PIZgOw5+bi09ifndSMUg6Pu
	 SBcZj+IhaDAR0z3bc6SfeGcPmjQvgoRYlFKz/iKxUED/8QkGs8uB9cNmos93pL495J
	 NXdA035THee9lHe8V5hdzJBAPFs5jWlBFKpe5bzr3vs+R1j21omP9eJIItBPXuLVUe
	 AfP65GL9MMizQ==
From: Christian Brauner <brauner@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	Josef Bacik <josef@toxicpanda.com>,
	Chris Mason <mason@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Eric Dumazet <edumazet@kernel.org>,
	Thomas Gleixner <tglx@kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Christoph Hellwig <hch@lst.de>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Joel Granados <joel.granados@kernel.org>,
	Kees Cook <kees@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jan Kara <jack@suse.com>,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-um@lists.infradead.org,
	linux-wireless@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org,
	ntfs3@lists.linux.dev,
	platform-driver-x86@vger.kernel.org,
	coreteam@netfilter.org,
	kexec@lists.infradead.org,
	linux-pci@vger.kernel.org,
	linux-sound@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	ibm-acpi-devel@lists.sourceforge.net,
	jfs-discussion@lists.sourceforge.net,
	linux-alpha@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-hwmon@vger.kernel.org,
	linux-mm@kvack.org,
	linux-sh@vger.kernel.org,
	linux-usb@vger.kernel.org,
	samba-technical@lists.samba.org,
	sparclinux@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org,
	linux-doc@vger.kernel.org,
	linux-serial@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	Takashi Iwai <tiwai@suse.de>,
	linux-input@vger.kernel.org,
	linux-raid@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-modules@vger.kernel.org,
	linux-debuggers@vger.kernel.org,
	"Christian Brauner (Amutable)" <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	stable@vger.kernel.org
Subject: [PATCH RESEND v2 41/51] scsi: esas2r: bound the lengths of the HBA, SMP and firmware ioctls
Date: Wed,  4 Nov 2026 20:26:02 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-41-021c84d852e0@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=6672; i=brauner@kernel.org; h=from:subject:message-id; bh=2aMnK188zalc9NOhuhHvIjnHW4mP6VOaoGggC08Jevg=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bvw38ZaPqVai5VQBfePvMdFLldYLB/4OlJ7R5jbN+ cnWF7WVHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABNx2czIcNZ6Tv0XfyY9Wfn1 Dz4wh21XeGn22GPftdT+xljFz2cVORkZNr9fFHrlp67vsf/hjvXt0SfXTw4XF5NakZJvybXowMa J/AA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

esas2r_ioctl_handler() copies in a struct atto_express_ioctl, a bit over
512k, and hands the union member for the command to the handlers. For
EXPRESS_IOCTL_HBA and EXPRESS_IOCTL_SMP the length of the buffered ioctl
is the size of the member plus lengths that come straight from
userspace:

  bi.length = sizeof(struct atto_ioctl) + ioctl_hba->data_length;

  bi.length = sizeof(struct atto_ioctl_smp)
	    + le32_to_cpu(si->req_length)
	    + le32_to_cpu(si->rsp_length);

handle_buffered_ioctl() copies bi.length bytes from the member into a
DMA buffer and, once the adapter is done, copies the DMA buffer back
over the member. Nothing checks that the lengths fit into the struct
that was copied in. So a large data_length makes it read past the
struct and then write the DMA buffer back over the memory behind it.

The firmware commands pass sizeof(struct atto_express_ioctl) to
esas2r_{read,write}_{fw,fs}() as the length of data.fwrw.image, which
starts 28 bytes into the struct. So they can read and write 28 bytes
past it as well.

The handler is reachable through /proc/scsi/esas2r/ATTONode. It is
created with mode 0, which procfs turns into 0444, and esas2r doesn't
check for a capability anywhere. So any local user can do this on a
machine with such an adapter.

Bound all of these by the room from the member to the end of the
struct. read_hw() passes handle_hba_ioctl() a single struct atto_ioctl
and only ever returns that, so there the data length has to be zero.

Reported-by: Chris Mason <mason@kernel.org>
Fixes: 26780d9e12ed ("[SCSI] esas2r: ATTO Technology ExpressSAS 6G SAS/SATA RAID Adapter Driver")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/scsi/esas2r/esas2r.h       |  2 +-
 drivers/scsi/esas2r/esas2r_ioctl.c | 41 ++++++++++++++++++++++++--------------
 drivers/scsi/esas2r/esas2r_main.c  |  3 ++-
 3 files changed, 29 insertions(+), 17 deletions(-)

diff --git a/drivers/scsi/esas2r/esas2r.h b/drivers/scsi/esas2r/esas2r.h
index a763edd05fe4..10101f50b282 100644
--- a/drivers/scsi/esas2r/esas2r.h
+++ b/drivers/scsi/esas2r/esas2r.h
@@ -967,7 +967,7 @@ int esas2r_write_params(struct esas2r_adapter *a, struct esas2r_request *rq,
 int esas2r_ioctl_handler(void *hostdata, unsigned int cmd, void __user *arg);
 int esas2r_ioctl(struct scsi_device *dev, unsigned int cmd, void __user *arg);
 u8 handle_hba_ioctl(struct esas2r_adapter *a,
-		    struct atto_ioctl *ioctl_hba);
+		    struct atto_ioctl *ioctl_hba, size_t room);
 enum scsi_qc_status esas2r_queuecommand(struct Scsi_Host *host,
 					struct scsi_cmnd *cmd);
 int esas2r_show_info(struct seq_file *m, struct Scsi_Host *sh);
diff --git a/drivers/scsi/esas2r/esas2r_ioctl.c b/drivers/scsi/esas2r/esas2r_ioctl.c
index c93d9265e100..80ae5b9d45db 100644
--- a/drivers/scsi/esas2r/esas2r_ioctl.c
+++ b/drivers/scsi/esas2r/esas2r_ioctl.c
@@ -311,17 +311,27 @@ static int smp_ioctl_callback(struct esas2r_adapter *a,
 	return true;
 }
 
+/* The room from @member to the end of a struct atto_express_ioctl. */
+#define EXPRESS_IOCTL_ROOM(member)				\
+	(sizeof(struct atto_express_ioctl) -			\
+	 offsetof(struct atto_express_ioctl, member))
+
 static u8 handle_smp_ioctl(struct esas2r_adapter *a, struct atto_ioctl_smp *si)
 {
 	struct esas2r_buffered_ioctl bi;
+	u64 length = (u64)sizeof(struct atto_ioctl_smp) +
+		     le32_to_cpu(si->req_length) +
+		     le32_to_cpu(si->rsp_length);
+
+	/* The request and the response follow @si in the same buffer. */
+	if (length > EXPRESS_IOCTL_ROOM(data.ioctl_smp))
+		return IOCTL_INVALID_PARAM;
 
 	memset(&bi, 0, sizeof(bi));
 
 	bi.a = a;
 	bi.ioctl = si;
-	bi.length = sizeof(struct atto_ioctl_smp)
-		    + le32_to_cpu(si->req_length)
-		    + le32_to_cpu(si->rsp_length);
+	bi.length = length;
 	bi.offset = 0;
 	bi.callback = smp_ioctl_callback;
 	return handle_buffered_ioctl(&bi);
@@ -1221,11 +1231,16 @@ static void hba_ioctl_done_callback(struct esas2r_adapter *a,
 	}
 }
 
+/* @room is the size of the buffer that starts with @ioctl_hba. */
 u8 handle_hba_ioctl(struct esas2r_adapter *a,
-		    struct atto_ioctl *ioctl_hba)
+		    struct atto_ioctl *ioctl_hba, size_t room)
 {
 	struct esas2r_buffered_ioctl bi;
 
+	/* The data follows @ioctl_hba in the same buffer. */
+	if (ioctl_hba->data_length > room - sizeof(struct atto_ioctl))
+		return IOCTL_INVALID_PARAM;
+
 	memset(&bi, 0, sizeof(bi));
 
 	bi.a = a;
@@ -1349,31 +1364,27 @@ int esas2r_ioctl_handler(void *hostdata, unsigned int cmd, void __user *arg)
 			err = esas2r_write_fw(a,
 					      (char *)ioctl->data.fwrw.image,
 					      0,
-					      sizeof(struct
-						     atto_express_ioctl));
+					      EXPRESS_IOCTL_ROOM(data.fwrw.image));
 
 			if (err >= 0) {
 				err = esas2r_read_fw(a,
 						     (char *)ioctl->data.fwrw.
 						     image,
 						     0,
-						     sizeof(struct
-							    atto_express_ioctl));
+						     EXPRESS_IOCTL_ROOM(data.fwrw.image));
 			}
 		} else if (ioctl->data.fwrw.img_type == FW_IMG_FS_API) {
 			err = esas2r_write_fs(a,
 					      (char *)ioctl->data.fwrw.image,
 					      0,
-					      sizeof(struct
-						     atto_express_ioctl));
+					      EXPRESS_IOCTL_ROOM(data.fwrw.image));
 
 			if (err >= 0) {
 				err = esas2r_read_fs(a,
 						     (char *)ioctl->data.fwrw.
 						     image,
 						     0,
-						     sizeof(struct
-							    atto_express_ioctl));
+						     EXPRESS_IOCTL_ROOM(data.fwrw.image));
 			}
 		} else {
 			ioctl->header.return_code = IOCTL_BAD_FLASH_IMGTYPE;
@@ -1441,9 +1452,9 @@ int esas2r_ioctl_handler(void *hostdata, unsigned int cmd, void __user *arg)
 		break;
 
 	case EXPRESS_IOCTL_HBA:
-		ioctl->header.return_code = handle_hba_ioctl(a,
-							     &ioctl->data.
-							     ioctl_hba);
+		ioctl->header.return_code =
+			handle_hba_ioctl(a, &ioctl->data.ioctl_hba,
+					 EXPRESS_IOCTL_ROOM(data.ioctl_hba));
 		break;
 
 	case EXPRESS_IOCTL_VDA:
diff --git a/drivers/scsi/esas2r/esas2r_main.c b/drivers/scsi/esas2r/esas2r_main.c
index ada278c24c51..75a70ae9441b 100644
--- a/drivers/scsi/esas2r/esas2r_main.c
+++ b/drivers/scsi/esas2r/esas2r_main.c
@@ -178,7 +178,8 @@ static ssize_t read_hw(struct file *file, struct kobject *kobj,
 	if (!a->local_atto_ioctl)
 		return -ENOMEM;
 
-	if (handle_hba_ioctl(a, a->local_atto_ioctl) != IOCTL_SUCCESS)
+	if (handle_hba_ioctl(a, a->local_atto_ioctl,
+			     sizeof(struct atto_ioctl)) != IOCTL_SUCCESS)
 		return -ENOMEM;
 
 	memcpy(buf, a->local_atto_ioctl, length);

-- 
2.53.0

