Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:47767 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751417AbbG1QNV convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2015 12:13:21 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Kinglong Mee'" <kinglongmee@gmail.com>,
        "'J. Bruce Fields'" <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>
Cc: <tigran.mkrtchyan@desy.de>
References: <55B76B9D.2090103@gmail.com>
In-Reply-To: <55B76B9D.2090103@gmail.com>
Subject: RE: [PATCH 4/4] 4.1 create_session: Skip test of CB_NULL for nfs4.1
Date: Tue, 28 Jul 2015 09:03:38 -0700
Message-ID: <008401d0c94e$f90e7250$eb2b56f0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Why are we removing these two test cases? The Ganesha NFS server at least passes them.

Frank

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Kinglong Mee
> Sent: Tuesday, July 28, 2015 4:47 AM
> To: J. Bruce Fields; linux-nfs@vger.kernel.org
> Cc: tigran.mkrtchyan@desy.de; kinglongmee@gmail.com
> Subject: [PATCH 4/4] 4.1 create_session: Skip test of CB_NULL for nfs4.1
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  nfs4.1/server41tests/st_create_session.py | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_create_session.py
> b/nfs4.1/server41tests/st_create_session.py
> index b42e0ab..4c56bb4 100644
> --- a/nfs4.1/server41tests/st_create_session.py
> +++ b/nfs4.1/server41tests/st_create_session.py
> @@ -333,7 +333,7 @@ def testManyClients(t, env):
>  def testCallbackProgram(t, env):
>      """Check server can handle random transient program number
> 
> -    FLAGS: create_session all
> +    FLAGS:
>      CODE: CSESS20
>      """
>      cb_occurred = threading.Event()
> @@ -360,7 +360,7 @@ def testCallbackProgram(t, env):
>  def testCallbackVersion(t, env):
>      """Check server sends callback program with a version listed in
> nfs4client.py
> 
> -    FLAGS: create_session all
> +    FLAGS:
>      CODE: CSESS21
>      """
>      cb_occurred = threading.Event()
> --
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

