Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:60912 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753937Ab1I2AKW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Sep 2011 20:10:22 -0400
Received: from public by plane.gmane.org with local (Exim 4.69)
	(envelope-from <public@plane.gmane.org>)
	id 1R94Ci-0004OQ-Aj
	for linux-nfs@vger.kernel.org; Thu, 29 Sep 2011 02:10:20 +0200
Subject: Re: NFS mounts and its propagation
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>
Cc: Sreeram B S
	<public-sreeramb-HgOvQuBEEgTQT0dZR+AlfA@plane.gmane.org>,
        public-linux-nfs-u79uwXL29TY76Z2rM5mHXA@plane.gmane.org
Date: Wed, 28 Sep 2011 20:08:38 -0400
In-Reply-To: <4E83A799.1090303@linux.vnet.ibm.com>
References: <4E805C16.4030509@netapp.com>
	 <4E83A799.1090303@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1317254918.2764.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0




On Wed, 2011-09-28 at 16:02 -0700, Venkateswararao Jujjuri wrote: 
> 
> On 09/26/2011 04:03 AM, Sreeram B S wrote:
> > Hi,
> > I am Sreeram. This question is related to NFS.
> > I have a typical scenario. Please assume that there are 3 machines M1,
> > M2, M3. Each of them are having directories /tmp/abc in them. All the
> > NFS permissions are set appropriately.
> > Now, a user mounts M2's /tmp/abc on M1's /tmp/abc by issuing mount
> > command on M1. Mount is successful.
> > Then the user mounts M3's /tmp/abc on M2's /tmp/abc by issuing mount
> > command on M2. Mount successful.
> > Now I would expect the contents of M3's /tmp/abc to be shown as output
> > of 'ls' issue on M1. But this is not happening. I am unable to
> > comprehend the reason. Could you please guide me?
> 
> What are you seeing instead? Are you seeing M2's contents on M1?
> Did you try to change the order of the experiment? i.e First mount M3 on 
> M2 and then mount M2 on M1? Just curious to see if there is any change 
> in the behavior.

As Bruce said, re-exporting of NFS-mounted filesystems is not supported
by the Linux server.

Just mount M3's contents directly onto M1, or use a NFSv4 referral (man
5 exports0.

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com



