Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12106 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750862Ab0LOUcL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 15:32:11 -0500
Subject: Re: System CPU increasing on idle 2.6.36
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Simon Kirby <sim@hostway.ca>, linux-nfs@vger.kernel.org
In-Reply-To: <20101215201908.GB9646@fieldses.org>
References: <1291869437.2821.6.camel@heimdal.trondhjem.org>
	 <20101214233843.GB836@hostway.ca> <20101215011021.GA24594@hostway.ca>
	 <20101215015609.GB24594@hostway.ca> <20101215180813.GA7773@fieldses.org>
	 <1292437333.3068.14.camel@heimdal.trondhjem.org>
	 <20101215183816.GB7773@fieldses.org>
	 <1292441630.3068.55.camel@heimdal.trondhjem.org>
	 <20101215194956.GA9646@fieldses.org>
	 <1292443028.3068.60.camel@heimdal.trondhjem.org>
	 <20101215201908.GB9646@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Dec 2010 15:32:08 -0500
Message-ID: <1292445128.3068.71.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-15 at 15:19 -0500, J. Bruce Fields wrote:

> Could you give an example of a case in which all of the following are
> true?:
> 	- the administrator explicitly requests numeric id's (for
> 	  example by setting nfs4_disable_idmapping).
> 	- numeric id's work as long as the client uses auth_sys.
> 	- they no longer work if that same client switches to krb5.

Trivially:

Server /etc/passwd maps trondmy to uid 1000
Client /etc/passwd maps trondmy to uid 500

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

