Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46163 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754552Ab1LLWmU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 17:42:20 -0500
Date: Mon, 12 Dec 2011 17:42:19 -0500
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] client: test OPEN+WRITE+CLOSE in a single compound
Message-ID: <20111212224219.GC22927@fieldses.org>
References: <1323721588-8259-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323721588-8259-1-git-send-email-tigran.mkrtchyan@desy.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I already applied some previous version of these--could you check

	git://linux-nfs.org/~bfields/pynfs.git

and let me know if I got anything wrong?  (If so, incremental patches on
top of that would be appreciated.

Thanks--b.

On Mon, Dec 12, 2011 at 09:26:26PM +0100, Tigran Mkrtchyan wrote:
> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.1/server41tests/st_open.py |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
> index 1c965b2..c809c95 100644
> --- a/nfs4.1/server41tests/st_open.py
> +++ b/nfs4.1/server41tests/st_open.py
> @@ -275,3 +275,19 @@ def testLockLockU(t, env):
>  	op.locku(WRITE_LT, 0, current_stateid, 0, NFS4_UINT64_MAX) ]
>      res = sess1.compound([op.putfh(fh)] + lock_ops)
>      check(res, NFS4_OK)
> +
> +def testOpenWriteClose(t, env):
> +    """test current state id processing by having OPEN, WRITE and CLOSE
> +       in a single compound
> +
> +    FLAGS: open all
> +    CODE: OPEN33
> +    """
> +    current_stateid = stateid4(1, '\0' * 12)
> +    sess1 = env.c1.new_client_session(env.testname(t))
> +
> +    data = "write test data"
> +    open_op = open_create_file_op(sess1, env.testname(t), open_create=OPEN4_CREATE)
> +    res = sess1.compound(open_op + [op.write(current_stateid, 5, FILE_SYNC4, data),
> +        op.close(0, current_stateid)])
> +    check(res, NFS4_OK)
> \ No newline at end of file
> -- 
> 1.7.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
