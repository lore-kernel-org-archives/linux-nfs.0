Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15405 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756349Ab1CWSR5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 14:17:57 -0400
Subject: RE: [PATCH 3/3] NFS: Detect loops in a readdir due to bad cookies
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: peter.staubach@emc.com
Cc: bjschuma@netapp.com, linux-nfs@vger.kernel.org
In-Reply-To: <5E6794FC7B8FCA41A704019BE3C70E8B0693F02D@MX31A.corp.emc.com>
References: <4D8A3060.807@netapp.com>
	 <5E6794FC7B8FCA41A704019BE3C70E8B0693F02D@MX31A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Mar 2011 14:17:47 -0400
Message-ID: <1300904267.11677.47.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-23 at 14:10 -0400, peter.staubach@emc.com wrote:
> Doesn't returning identical cookies for multiple, different entries in the same directory constitute a protocol violation?

Yes. Unfortunately quite a few common filesystems seem quite happy to do
so.

Most of the time they get away with it, but occasionally we do get
support requests from people asking 'why is my NFS client looping
forever?'.
With Bryan's patches, we now have a way to have the client error out
instead of looping, and notify the admin that their server is exporting
a broken underlying filesystem.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

