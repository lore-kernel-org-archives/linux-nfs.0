Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5931 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932503Ab1CWSsh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 14:48:37 -0400
Subject: RE: [PATCH 3/3] NFS: Detect loops in a readdir due to bad cookies
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: peter.staubach@emc.com
Cc: bfields@fieldses.org, bjschuma@netapp.com, linux-nfs@vger.kernel.org
In-Reply-To: <5E6794FC7B8FCA41A704019BE3C70E8B0693F05F@MX31A.corp.emc.com>
References: <4D8A3060.807@netapp.com>  <20110323182524.GB25284@fieldses.org>
	 <1300905243.11677.53.camel@lade.trondhjem.org>
	 <5E6794FC7B8FCA41A704019BE3C70E8B0693F05F@MX31A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Mar 2011 14:48:35 -0400
Message-ID: <1300906115.11677.58.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-23 at 14:42 -0400, peter.staubach@emc.com wrote:
> Although I think that it is a good thing to protect the client against broken servers, it does seem like the right solution is to get the server fixed...

Don't get me wrong: I fully agree with that!

The reason for wanting this code is to cut down on the amount of
debugging we have to do in order to detect those broken servers.
Detecting duplicate cookies in a wireshark trace can be very
time-consuming if you are dealing with a 10^6-entry directory.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

