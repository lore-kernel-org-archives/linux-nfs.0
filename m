Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19113 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757726Ab1FVDQr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2011 23:16:47 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <19969.24218.37250.26939@regina.usersys.redhat.com>
Date: Wed, 22 Jun 2011 13:16:42 +1000
From: Max Matveev <makc@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>, steved@redhat.com,
        linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Subject: Re: [PATCH] manpage: add info about IPv6 configuration to
 exports(5) (try #2)
In-Reply-To: <20110621160057.GC25534@fieldses.org>
References: <1308665441-16704-1-git-send-email-jlayton@redhat.com>
	<20110621160057.GC25534@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 21 Jun 2011 12:00:57 -0400, J Bruce Fields wrote:

 bfields> On Tue, Jun 21, 2011 at 10:10:41AM -0400, Jeff Layton wrote:

 >> +of host. IPv6 addresses must use a contiguous mask length. Wildcard characters

 bfields> People use non-contiguous masks?

I think IPv6 people call those things "prefix".

max

