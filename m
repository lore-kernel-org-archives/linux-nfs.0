From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/4] sunrpc: parse and return errors reported by gssd
Date: Thu, 07 Jan 2010 14:11:56 -0500
Message-ID: <1262891516.3309.14.camel@localhost>
References: <1262875325-4488-1-git-send-email-jlayton@redhat.com>
	 <1262875325-4488-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29419 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546Ab0AGTMD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2010 14:12:03 -0500
In-Reply-To: <1262875325-4488-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-01-07 at 09:42 -0500, Jeff Layton wrote:

> @@ -646,6 +652,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
>  		err = PTR_ERR(p);
>  		switch (err) {
>  		case -EACCES:
> +		case -EKEYEXPIRED:
>  			gss_msg->msg.errno = err;
>  			err = mlen;
>  			break;

              ^^^^^^^^^^^^^^^^^^^^^ This doesn't appear to want to apply
to mainline. Did you perhaps skip a patch?

Trond
