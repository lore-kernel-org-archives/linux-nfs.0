Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23267 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbcBJVTW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Feb 2016 16:19:22 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: Kernel crash in Centos 6.6
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <9eeh3fd9sbcxvpbtxeka4hci.1455121291462@email.android.com>
Date: Wed, 10 Feb 2016 16:19:17 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <709CC9F2-40B0-45CB-BBB2-5DFC43A3AEC7@oracle.com>
References: <9eeh3fd9sbcxvpbtxeka4hci.1455121291462@email.android.com>
To: "fedele.stabile" <fedele.stabile@fis.unical.it>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Feb 10, 2016, at 11:21 AM, fedele.stabile <fedele.stabile@fis.unical.it> wrote:
> 
> No, the client hangs and the only way to gain control is power cycle  of client. ...

File a bug with your distributor. They should be able to
help you with triage steps.


> -------- Messaggio originale --------
> Da: Chuck Lever <chuck.lever@oracle.com>
> Data: 10/02/2016 16:28 (GMT+01:00)
> A: fedele.stabile@fis.unical.it
> Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
> Oggetto: Re: Kernel crash in Centos 6.6
> 
> Fedele-
> 
> > On Feb 10, 2016, at 7:07 AM, Fedele Stabile <fedele.stabile@fis.unical.it> wrote:
> > 
> > Hello all,
> > I have a kernel crash when I mount an NFS volume using RDMA transport.
> > On client and server is installed Centos 6.6 kernel 2.6.32
> > -504.8.1.el6.x86_64
> > I use nfs v4
> > The client hangs if I execute 
> > mount -t nfs -o rdma ib-server:/data /data
> > Server and client are connected throw Infiniband network and Qlogic
> > adapters.
> 
> I assume you mean that the mount command hangs, not that
> the whole client deadlocks.
> 
> Add "port=20049" to the mount options.
> 
> 
> --
> Chuck Lever
> 
> 
> 
> 
> 

--
Chuck Lever




