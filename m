Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:35302 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934641Ab3JPTKw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 15:10:52 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Here's a nugget...
Date: Wed, 16 Oct 2013 19:10:50 +0000
Message-ID: <1381950650.17178.18.camel@leira.trondhjem.org>
References: <1381949943.17178.12.camel@leira.trondhjem.org>
	 <20131016190245.GD19067@fieldses.org>
In-Reply-To: <20131016190245.GD19067@fieldses.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-10-16 at 15:02 -0400, J. Bruce Fields wrote:
+AD4- On Wed, Oct 16, 2013 at 06:59:04PM +-0000, Myklebust, Trond wrote:
+AD4- +AD4- In gss+AF8-krb5+AF8-add+AF8-padding():
+AD4- +AD4- 
+AD4- +AD4- 	memset(p, padding, padding)+ADs-
+AD4- 
+AD4- RFC 1964 1.2.2.3:
+AD4- 
+AD4- 	+ACI-Data padding: Before encryption and/or signature calculation,
+AD4- 	plaintext data is padded to the next highest multiple of 8
+AD4- 	bytes, by appending between 1 and 8 bytes, the value of each
+AD4- 	such byte being the total number of pad bytes.+ACI-
+AD4- 
+AD4- You could add a comment referencing that if you think the memset is
+AD4- confusing.

Wow... In which bar did they hold that IETF meeting?

Definitely needs a comment.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
