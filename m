Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mrout3.yahoo.com ([216.145.54.173]:21722 "EHLO mrout3.yahoo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759520Ab2C2QGR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Mar 2012 12:06:17 -0400
From: Kevin Graham <mahargk@yahoo-inc.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Jim Rees <rees@umich.edu>, Vivek Trivedi <vtrivedi018@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Namjae Jeon <linkinjeon@gmail.com>,
        "amit.sahrawat83@gmail.com" <amit.sahrawat83@gmail.com>
Date: Thu, 29 Mar 2012 08:52:57 -0700
Subject: Re: NFS: low read/stat performance on small files
Message-ID: <8E325A03-6EE9-4303-AB52-8BA252E39325@corp.yahoo.com>
References: <CAKX=r8A90b25VKXC1qtAota9DqDrj37xFT511DuvrZ=1Eux6Xw@mail.gmail.com>
 <20120323114913.GB24489@umich.edu>
 <1332505002.20500.14.camel@lade.trondhjem.org>
In-Reply-To: <1332505002.20500.14.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 23, 2012, at 5:16 AM, Myklebust, Trond wrote:

> All these tasks have to be done in series (you cannot do them in parallel), and so the
> latency of each task is limited by the round-trip time to the server.


Will the v4 client at least collapse them into a single compound op?

