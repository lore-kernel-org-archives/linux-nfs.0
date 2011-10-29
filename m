Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:32940 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039Ab1J2FZs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2011 01:25:48 -0400
Message-ID: <4EAB8E4D.5050001@panasas.com>
Date: Fri, 28 Oct 2011 22:25:33 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, Benny Halevy <benny@tonian.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] nfsd4: DEBUG: XDR_ERROR()
References: <1319741351-3794-1-git-send-email-benny@tonian.com> <20111028113443.GA3445@fieldses.org> <4EAA9B73.2030306@tonian.com>
In-Reply-To: <4EAA9B73.2030306@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/28/2011 05:09 AM, Benny Halevy wrote:
> 
> I agree with all of the above but its a project larger than I can
> chew right now.  This patch just improves the existing mechanism, for
> development use, to help catch parser bugs rather than actual xdr errors.
> 
<>

>>>  
>>> +#define XDR_ERROR()	do {			\
>>> +	dprintk("NFSD: xdr error (%s:%d)\n",	\
>>> +			__FILE__, __LINE__);	\
>>> +	goto xdr_error;				\
>>> +} while (0)
>>> +

What about a compromise:

+#define GOTO_XDR_ERROR()	do {			\
+	dprintk("NFSD: xdr error (%s:%d)\n",	\
+			__FILE__, __LINE__);	\
+	goto xdr_error;				\
+} while (0)

or even:

+#define XDR_ERROR_GOTO(xdr_error)	do {	\
+	dprintk("NFSD: xdr error (%s:%d)\n",	\
+			__FILE__, __LINE__);	\
+	goto xdr_error;				\
+} while (0)

and XDR_ERROR_GOTO(xdr_error) every where.

So the patch below stays exactly the same size
but the goto is not masked out, and no one can
complain about things happening hidden underground.

Just My $0.017
Boaz
