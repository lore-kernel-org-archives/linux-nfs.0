Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e32.co.us.ibm.com ([32.97.110.150]:34293 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab2AQTod (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jan 2012 14:44:33 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Tue, 17 Jan 2012 12:44:28 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 6CE5E19D8060
	for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2012 12:43:52 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0HJhnqa302020
	for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2012 14:43:50 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0HJhjKl004926
	for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2012 12:43:46 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0HJhjwA004910
	for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2012 12:43:45 -0700
Date: Tue, 17 Jan 2012 13:43:45 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20120117194344.GA11005@us.ibm.com>
References: <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
 <20111113163632.GA28574@fieldses.org>
 <20111114080745.57083bfe@notabene.brown>
 <1321338825.8267.2.camel@lade.trondhjem.org>
 <20120113170914.GA31414@us.ibm.com>
 <20120114013834.GA20464@fieldses.org>
 <20120116165228.GA4990@us.ibm.com>
 <20120117151826.GB12274@fieldses.org>
 <20120117172231.GA21603@us.ibm.com>
 <20120117184743.GB15460@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120117184743.GB15460@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields [bfields@fieldses.org] wrote:
> > I think so too. We think Volatile file handle support on the client side
> > is simpler for our use case (read only NFS file systems)
> 
> Won't it be confusing to applications if inode numbers change on
> migration?

Some applications do depends on stable inode numbers. We can't have VFH
and stable inode numbers! We don't have any such apps in our
environment. Mount option for VFH (use at your own risk) would work fine
for us.

