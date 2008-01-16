From: Risto Bell <reb-+wT8y+m8/X5BDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching
 negative dentries
Date: Wed, 16 Jan 2008 13:12:37 -0800
Message-ID: <478E7345.8080003@cypress.com>
References: <20080115163013.GC18911@newbie.thebellsplace.net> <1200415972.7702.7.camel@heimdal.trondhjem.org> <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com> <20080116012209.GB26010@newbie.thebellsplace.net> <1200451350.28088.43.camel@heimdal.trondhjem.org> <478DFD5A.1040501@RedHat.com> <01AE8AF878612047A442668306EAEB05018178E7@SACEXMV01.hq.netapp.com> <1200516219.6932.22.camel@heimdal.trondhjem.org> <C8097339-F9C5-4350-823E-A99945F4600E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.cypress.com ([157.95.67.4]:62247 "EHLO ns1.cypress.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751001AbYAPVh3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jan 2008 16:37:29 -0500
Received: from corpmail.cypress.com (corpmail [157.95.1.2])
	by ns1.cypress.com (8.12.10/8.12.10) with ESMTP id m0GL8JOJ008153
	for <linux-nfs@vger.kernel.org>; Wed, 16 Jan 2008 13:08:19 -0800 (PST)
Received: from meson.design.cypress.com (meson.design.cypress.com [172.17.2.36])
	by corpmail.cypress.com (8.12.10/8.12.10) with ESMTP id m0GLCcnm007321
	for <linux-nfs@vger.kernel.org>; Wed, 16 Jan 2008 13:12:38 -0800 (PST)
Received: from mopar.design.cypress.com (mopar [172.17.14.88])
	by meson.design.cypress.com (8.9.3+Sun/8.9.3) with ESMTP id NAA01311
	for <linux-nfs@vger.kernel.org>; Wed, 16 Jan 2008 13:12:37 -0800 (PST)
Received: from mopar.design.cypress.com (localhost [127.0.0.1])
	by mopar.design.cypress.com (8.12.11/8.12.11) with ESMTP id m0GLCb6e004232
	for <linux-nfs@vger.kernel.org>; Wed, 16 Jan 2008 13:12:37 -0800
In-Reply-To: <C8097339-F9C5-4350-823E-A99945F4600E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Already decided not to go the distance, with separate controls of
time-to-live of positive and negative lookup cache entries (or is it
not considered good form to overload negttl=0 as means to disable)?
