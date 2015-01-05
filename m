Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:43207 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409AbbAEK6c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2015 05:58:32 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Y85Ml-0003PT-1x
	for linux-nfs@vger.kernel.org; Mon, 05 Jan 2015 11:58:31 +0100
Received: from barriere.frankfurter-softwarefabrik.de ([217.11.197.1])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 05 Jan 2015 11:58:31 +0100
Received: from lvml by barriere.frankfurter-softwarefabrik.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 05 Jan 2015 11:58:31 +0100
To: linux-nfs@vger.kernel.org
From: Lutz Vieweg <lvml@5t9.de>
Subject: Re: xprt_adjust_timeout followed by lockd: server not responding
 / server OK
Date: Mon, 05 Jan 2015 11:58:18 +0100
Message-ID: <m8dqoa$2tu$1@ger.gmane.org>
References: <1416877610.325.37.camel@abezella-laptop.us.archive.org>	 <m86lsu$4l9$1@ger.gmane.org> <1420230301.10991.1.camel@primarydata.com> <54A83951.2040709@5t9.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
In-Reply-To: <54A83951.2040709@5t9.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/03/2015 07:47 PM, Lutz Vieweg wrote:
> On 01/02/2015 09:25 PM, Trond Myklebust wrote:
>> Does the following patch help?

Yes, the symptom is gone. Thanks a lot!

Regards,

Lutz Vieweg


