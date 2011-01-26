Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp11.nmdp.org ([198.175.249.53]:36060 "EHLO
	mn4s31001.nmdp.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751724Ab1AZPTs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jan 2011 10:19:48 -0500
From: Dan Burkland <dburklan@NMDP.ORG>
To: "Red Hat Enterprise Linux 6 (Santiago) discussion mailing-list"
	<rhelv6-list@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "rhelv6-list-bounces@redhat.com" <rhelv6-list-bounces@redhat.com>
Date: Wed, 26 Jan 2011 09:02:17 -0600
Subject: Re: [rhelv6-list] NFSv4 automount - nss_getpwnam name
 'user@domain.com' does not map into domain 'localdomain'
Message-ID: <0CC353FB-8FC5-4126-B810-FDBDB6E6531C@nmdp.org>
References: <20110119002907.GA25400@esri.com>
 <OF2761AC3A.66844802-ON8625781D.004EE4C7-8625781D.004EE7C9@uscmail.uscourts.gov>
 <20110119150450.GA20013@esri.com>
 <OFAB65B798.3724E99D-ON8625781D.0056CEF8-8625781D.0057212F@uscmail.uscourts.gov>
In-Reply-To: <OFAB65B798.3724E99D-ON8625781D.0056CEF8-8625781D.0057212F@uscmail.uscourts.gov>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

/etc/idmapd.conf is configured the same way on both the NFSv4 Server & Client correct? (I assume this is correct). I've run into this several times and usually a reboot of the "idmapd" service on the client fixes the issue (make sure that the NFS share is not mounted on the client).

Regards,

Dan

