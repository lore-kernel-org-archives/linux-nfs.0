From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/5] nfs-utils: query for remote port using rpcbind
	instead of getaddrinfo
Date: Tue, 7 Apr 2009 12:32:53 -0400
Message-ID: <20090407163253.GD24157@fieldses.org>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com> <1239117946-7535-4-git-send-email-jlayton@redhat.com> <41F98279-F000-4C1C-8E44-3568C89FC2BD@oracle.com> <20090407162005.GC24157@fieldses.org> <65C78FA4-2A84-498E-8857-BBB6F59B206C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:56987 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbZDGQcz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2009 12:32:55 -0400
In-Reply-To: <65C78FA4-2A84-498E-8857-BBB6F59B206C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 07, 2009 at 12:29:23PM -0400, Chuck Lever wrote:
> On Apr 7, 2009, at 12:20 PM, J. Bruce Fields wrote:
>> In recent kernels that information is in the "info" file for the given
>> client in rpc_pipefs.  Kevin and Olga have patches to support that in
>> gssd, if they aren't already in upstream nfs-utils.
>
> The issue is we're not exactly sure what value the kernel is passing up 
> in the info file.  It seems to change over time.

I don't understand.  How does it change over time?

--b.
