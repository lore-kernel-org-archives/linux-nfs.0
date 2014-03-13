Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32666 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753351AbaCMQ7F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2014 12:59:05 -0400
Subject: Re: [PATCH v2 0/5] NFSv4 rpc.idmapd plugin
From: Simo Sorce <simo@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Noam Meltzer <noam@primarydata.com>, linux-nfs@vger.kernel.org,
        sssd-devel@lists.fedorahosted.org
In-Reply-To: <5321CDB6.7010803@RedHat.com>
References: <1393918676-20865-1-git-send-email-noam@primarydata.com>
	 <5321CDB6.7010803@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 13 Mar 2014 12:58:59 -0400
Message-ID: <1394729939.32465.231.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2014-03-13 at 11:24 -0400, Steve Dickson wrote:

> V4 servers now have an option of returning a uid string (aka "3606")
> where the NFS client just converts that into the uid.

Can the client tell the server *not to do that* ?

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

