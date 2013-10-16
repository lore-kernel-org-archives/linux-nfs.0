Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:23082 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761366Ab3JPSn2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 14:43:28 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Andi Kleen <andi@firstfloor.org>,
        "kwc@citi.umich.edu" <kwc@citi.umich.edu>
Subject: Re: [PATCH] sunrpc: trim off EC bytes in addition to the checksum
 blob when doing a GSSAPI v2 unwrap
Date: Wed, 16 Oct 2013 18:43:26 +0000
Message-ID: <1381949005.17178.10.camel@leira.trondhjem.org>
References: <1381427810-10633-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1381427810-10633-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-10 at 13:56 -0400, Jeff Layton wrote:
+AD4- As Bruce points out in RFC 4121, section 4.2.3:
+AD4- 
+AD4-    +ACI-In Wrap tokens that provide for confidentiality, the first 16 octets
+AD4-     of the Wrap token (the +ACI-header+ACI-, as defined in section 4.2.6), SHALL
+AD4-     be appended to the plaintext data before encryption.  Filler octets
+AD4-     MAY be inserted between the plaintext data and the +ACI-header.+ACIAIg-
+AD4- 
+AD4- ...and...
+AD4- 
+AD4-    +ACI-In Wrap tokens with confidentiality, the EC field SHALL be used to
+AD4-     encode the number of octets in the filler...+ACI-
+AD4- 
+AD4- It's possible for the client to stuff different data in that area on a
+AD4- retransmission, which could make the checksum come out wrong in the DRC
+AD4- code.
+AD4- 
+AD4- After decrypting the blob, we should trim off any extra count bytes in
+AD4- addition to the checksum blob.
+AD4- 
+AD4- Reported-by: +ACI-J. Bruce Fields+ACI- +ADw-bfields+AEA-fieldses.org+AD4-
+AD4- Signed-off-by: Jeff Layton +ADw-jlayton+AEA-redhat.com+AD4-
+AD4- ---
+AD4-  net/sunrpc/auth+AF8-gss/gss+AF8-krb5+AF8-wrap.c +AHw- 4 +-+---
+AD4-  1 file changed, 2 insertions(+-), 2 deletions(-)
+AD4- 
+AD4- diff --git a/net/sunrpc/auth+AF8-gss/gss+AF8-krb5+AF8-wrap.c b/net/sunrpc/auth+AF8-gss/gss+AF8-krb5+AF8-wrap.c
+AD4- index 1da52d1..ec1f4d0 100644
+AD4- --- a/net/sunrpc/auth+AF8-gss/gss+AF8-krb5+AF8-wrap.c
+AD4- +-+-+- b/net/sunrpc/auth+AF8-gss/gss+AF8-krb5+AF8-wrap.c
+AD4- +AEAAQA- -574,8 +-574,8 +AEAAQA- gss+AF8-unwrap+AF8-kerberos+AF8-v2(struct krb5+AF8-ctx +ACo-kctx, int offset, struct xdr+AF8-buf +ACo-buf)
+AD4-  	buf-+AD4-head+AFs-0+AF0-.iov+AF8-len -+AD0- GSS+AF8-KRB5+AF8-TOK+AF8-HDR+AF8-LEN +- headskip+ADs-
+AD4-  	buf-+AD4-len -+AD0- GSS+AF8-KRB5+AF8-TOK+AF8-HDR+AF8-LEN +- headskip+ADs-
+AD4-  
+AD4- -	/+ACo- Trim off the checksum blob +ACo-/
+AD4- -	xdr+AF8-buf+AF8-trim(buf, GSS+AF8-KRB5+AF8-TOK+AF8-HDR+AF8-LEN +- tailskip)+ADs-
+AD4- +-	/+ACo- Trim off the trailing +ACI-extra count+ACI- and checksum blob +ACo-/
+AD4- +-	xdr+AF8-buf+AF8-trim(buf, ec +- GSS+AF8-KRB5+AF8-TOK+AF8-HDR+AF8-LEN +- tailskip)+ADs-
+AD4-  	return GSS+AF8-S+AF8-COMPLETE+ADs-
+AD4-  +AH0-
+AD4-  

If this is just padding, then why would it be anything other than '0',
even on a retransmission? Clients are not supposed to leak random data
to the server...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
