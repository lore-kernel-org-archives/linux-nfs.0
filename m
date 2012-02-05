Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:56063 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753201Ab2BERhn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2012 12:37:43 -0500
Date: Sun, 5 Feb 2012 12:37:28 -0500
From: Jim Rees <rees@umich.edu>
To: Liam Gretton <liam.gretton@leicester.ac.uk>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: where can I ask user qns about nfs4?
Message-ID: <20120205173728.GA13418@umich.edu>
References: <4F2A2F9E.6030908@steve-ss.com>
 <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com>
 <4F2D9A0E.6010503@leicester.ac.uk>
 <4F2E4B50.5040701@steve-ss.com>
 <20120205141611.GA12826@umich.edu>
 <4F2EB471.9060508@leicester.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F2EB471.9060508@leicester.ac.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Liam Gretton wrote:

  On 05/02/2012 14:16, Jim Rees wrote:
  >There is a a NFS wiki, and it does have kerberos setup instructions:
  >http://wiki.linux-nfs.org/wiki/index.php/Enduser_doc_kerberos
  >
  >The wiki has mostly been used by developers for developer info but it might
  >be a good thing to use it for more general info too.
  
  Thanks, the problem isn't getting NFS with Kerberos to work in
  general, it's with AD as the KDC. It seems that NFS still only
  accepts DES encrypted Kerberos tickets, and these are specifically
  disabled in Windows Server 2008 R2.

Wasn't that fixed recently?
