Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D14147B406
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 13:15:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790255705; cv=none; b=U5Ad5SRdMPQeHEWdRf9K91S8C0nZhz7UWd7jY3PSPP1qgQbIR5XI/+jJ+0xlYzbw2wArN2lH03sUpkx+sMpJXIBTXiQN32eaPIKWOhgMvkC1vMrPUKYWpqWyAWbfnCkBe4W9uXnsAK4nxHGAOI9b2m/+eAsttl0nMsI8AP1XIdg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790255705; c=relaxed/simple;
	bh=7mzvuiptdV5LMqLLbKnhZbkKpa1//5ayIx2LkIHLcLE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=FSqhBIzSITQbc9taeKl5dl7+3xdB1LzTjGhVSj8tSQHiBo1liiWX8hQxbLVRy7Xagtpe8GKfhNEkCapPNqDGF8Fw2wPE3QJn5Kyzp2MSHTBj5c+xWgcJeE4oW+DrL2/19ecOH9obm/JLeZD03jFQR8t0XFXm51pS4eZIqaITLNE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Q1+akQ+B; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Q1+akQ+B"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EDC011F00893;
	Thu, 24 Sep 2026 13:15:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790255704;
	bh=LEOXTJvBi3x/D0CQKogODTi/ta2WWLGdkFvAY7LaPZQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Q1+akQ+Bto6W9FBZdFrWTTbnZbPslqaoEFmPlf+N8WLmqao6v81cYfmzxXzszKX4T
	 APQVZ49HK3COvH3LbUqpGy/TX+95LqYZwlCKgqu3YIufqoDfMs1EQlHYktVE3oh7eO
	 dlsma9cnYgt2lc0djeKwgAT/2RlRkDQ6WDNQMS018N/TN88re9uaVMo5T5zAkNUZQk
	 m4ws66UAZmiBe6Hc8zpo4G7UNWkfI+kFGamnwpjJWVKDsZdAtSfOOBeQPRU5kh70O4
	 J5ey1dgWaduBMfpuYqcRnDRQlGVvQr6IsC0OB2zNGVxXKVPuJ+W/KBS8WTMMznd44T
	 TU1yOtUg/c1nA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0E1DBF4006A;
	Thu, 24 Sep 2026 09:15:03 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 24 Sep 2026 09:15:03 -0400
X-ME-Sender: <xms:ViK1ajzsaO4Z5IRxuoHBY0aiB-kGAbTffdHSOGNXpjHdTyVYywu6BA>
    <xme:ViK1amFRyXHP294yLmu66VjsJR1_dveEz77zgh4Ro9VUe_-OEEzcIFnZsupHEZF8J
    Xc6oD-KsK6oz5Hzn_RR1o3Snlg-dN81J2EQQ8ADCqtwZ4J9ZC1dD1St>
X-ME-Proxy-Cause: dmFkZTFfGvVUHyCYvZPmVgkMPTI4K1qLwl7kz78e9PQ6r4MXGfutdnFacjQM9iQxEyL6/i
    yg0OZv0c73Et95yGr55d+vQXMCtrlJ7/zgEzEuF4Tj8XheQFIUzkn901BUzPDk4bzqGkEu
    urDcvalR6nWd2ADCMi/reVUA/Gv9wSmrtwAhYhTcnqE/U9aAp5W/U7/Ue+ozaWXRUwI/iJ
    23q1cWqVs36qY9kYDbh6CqHHvaB1hUS+qOSlEzpeyRZYwxsyAYeZkFj+Y46ut6lAHSca5q
    JvHZl+1vPksgQUGF22truUSDjEQOOcMNJ3lBvDt90az7NZULCb9U405VtnBku6xCl/7hEO
    JEcNVSU2HGReHvqagY4eD52faJaB301Fecx75UXQ0hx+rbvE8vSDqJ++Km/zAm5KsYu1JS
    budMFMzabjK04AYvm8L3szD9XAyhpxvaI4bXtT6q56Xos/+ON4P0q053kpEnR0OtOPhooj
    Uf9eSQpk9mFJXgvcldcHEH9IF4T69cstGdRf5kW91WYKaGNcrasJ6hJjpLLMnXBA1rzpmK
    FxccMh82Sj7jccddxxkEZI+0N8/FDWVJmYBTYZiptT4ZhfEHE2sWeo8SUZ1VU+Qvfnqosl
    PFl1+lrjU+4LvJurbhlQNeKKd0pV1lf/l2Xs0xHzddxTMY8ZMiO657WoOgYg
X-ME-Proxy: <xmx:ViK1aizHXR_kA50tBfuQg4iPHdoLbMdQ4Xi40jr_QIJe3wcFtv9bsg>
    <xmx:VyK1aqRTJ0HCFzCQiHWr5u6Uih59IRe2cwT0Nsspc0RjKr3nYOUhKw>
    <xmx:VyK1amhF1-gry2g9AHK7h0h2xgXJXQT3b8xWgaBywQs3FQefmQMvGg>
    <xmx:VyK1apndl-pXqEQ8RuJ9JMh8BAsvn9LQF3gBl36LIuGAWsV-Ti6NtQ>
    <xmx:VyK1ahul6tFl72mO9jGouf8PQ4aPMxAwPPb69TejAz_GgfbdubtEWUds>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id DD077780076; Thu, 24 Sep 2026 09:15:02 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ADGD3fXOw9Ro
Date: Thu, 24 Sep 2026 09:14:42 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>,
 "Calum Mackay" <calum.mackay@oracle.com>
Cc: "Chuck Lever" <chuck.lever@vger.kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Message-Id: <32c54d0b-0760-45ba-8ecb-edbbe0ff1210@app.fastmail.com>
In-Reply-To: <20260923-rply14-v1-1-f653557909af@kernel.org>
References: <20260923-rply14-v1-1-f653557909af@kernel.org>
Subject: Re: [PATCH pynfs] RPLY14: reconnect before retransmitting the call
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Sep 23, 2026, at 1:43 PM, Jeff Layton wrote:
> This test recently started failing with a change to the Linux kernel,
> but we believe that the test is wrong. This test replays the same call
> with the same XID over the same socket without reconnecting in between.
>
> There is language in RFC1813 that implies that a reconnect is necessary
> on a retransmit on a reliable transport like TCP.

I'd like to see a specific Section number and maybe even a block
quote.

But RFC 1813 is not normative for NFSv4.0. Does RFC 7530 have
anything to say about retransmission of NFS requests on
connection-oriented RPC transports?

One more below.


> Change the test to
> reconnect the socket before retransmitting.
>
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  nfs4.0/lib/rpc/rpc.py           | 25 +++++++++++++++++++++++++
>  nfs4.0/servertests/st_replay.py | 10 ++++++++--
>  2 files changed, 33 insertions(+), 2 deletions(-)
>
> diff --git a/nfs4.0/lib/rpc/rpc.py b/nfs4.0/lib/rpc/rpc.py
> index 7a80241aa127..c530847a46d9 100644
> --- a/nfs4.0/lib/rpc/rpc.py
> +++ b/nfs4.0/lib/rpc/rpc.py
> @@ -315,6 +315,31 @@ class RPCClient(object):
>          out.settimeout(self.timeout)
>          self.lock.release()
>          return out
> +
> +    def reconnect_same_port(self):
> +        """Drop the current connection and reconnect from the same local
> +        port, so the server sees a new transport with an unchanged
> +        (address, port) cache key. Used to test duplicate reply cache
> +        behavior across connections.
> +
> +        The old socket is reset (RST) rather than closed gracefully: a
> +        graceful close leaves the 4-tuple unusable until the server
> +        also closes, while an RST frees the source port immediately.
> +        """
> +        t = threading.currentThread()
> +        self.lock.acquire()
> +        old = self._socket[t]
> +        saddr = old.getsockname()
> +        old.setsockopt(socket.SOL_SOCKET, socket.SO_LINGER,
> +                       struct.pack('ii', 1, 0))
> +        old.close()
> +        out = self._socket[t] = socket.socket(self.af, socket.SOCK_STREAM)
> +        out.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
> +        out.bind(saddr)
> +        out.connect((self.remotehost, self.remoteport))
> +        out.settimeout(self.timeout)
> +        self.lock.release()
> +        return out
>         
>      def send(self, procedure, data=b'', program=None, version=None):
>          """Send an RPC call to the server
> diff --git a/nfs4.0/servertests/st_replay.py b/nfs4.0/servertests/st_replay.py
> index 48e5363432ec..fc8282151909 100644
> --- a/nfs4.0/servertests/st_replay.py
> +++ b/nfs4.0/servertests/st_replay.py
> @@ -4,7 +4,7 @@ from xdrdef.nfs4_type import *
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
> 
> -def _replay(env, c, ops, error=NFS4_OK):
> +def _replay(env, c, ops, error=NFS4_OK, newconn=False):
>      # Can send in an error list, but replays must return same error as orig
>      if type(error) is list:
>          check_funct = check
> @@ -18,6 +18,12 @@ def _replay(env, c, ops, error=NFS4_OK):
>      try:
>          c.get_new_xid = lambda : xid
> 
> +        if newconn:
> +            # Reconnect from the same source port before replaying:
> +            # servers may drop a retransmit that arrives on the same
> +            # connection as the original call.

This comment echoes the documenting comment in front of reconnect_same_port
and can be dropped.


> +            c.reconnect_same_port()
> +
>          # note: this is really cheesy: we happen to know the current
>          # Linux server implementation will drop a replay if it comes
>          # "too quickly" (<.02 seconds).
> @@ -260,4 +266,4 @@ def testMkdirReplay(t, env):
>      c = env.c1
>      c.init_connection()
>      ops = c.go_home() + [op.create(createtype4(NF4DIR), t.word(), {})]
> -    _replay(env, c, ops)
> +    _replay(env, c, ops, newconn=True)
>
> ---
> base-commit: cd4701827a8261fedbfb4c6e39029fb9671321a6
> change-id: 20260923-rply14-d24b334cd6fa
>
> Best regards,
> -- 
> Jeff Layton <jlayton@kernel.org>

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
