Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52575 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932154Ab3DYBnW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 21:43:22 -0400
Date: Wed, 24 Apr 2013 21:43:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: David Quigley <dpquigl@davequigley.com>, Steve Dickson <steved@redhat.com>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>, eparis@redhat.com,
        sds@tycho.nsa.gov
Subject: Re: [PATCH 04/17] Security: Add hook to calculate context based on a
 negative dentry.
Message-ID: <20130425014314.GU20275@fieldses.org>
References: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
 <1366834683-29075-5-git-send-email-SteveD@redhat.com>
 <20130424220258.GO20275@fieldses.org>
 <517858D1.5000406@RedHat.com>
 <faf7db0bcd9b208c201a652c718c720c@countercultured.net>
 <20130424230312.GS20275@fieldses.org>
 <dece1c7129e6927e9a92d38879818a46@countercultured.net>
 <5178867E.30704@schaufler-ca.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5178867E.30704@schaufler-ca.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 24, 2013 at 06:27:26PM -0700, Casey Schaufler wrote:
> On 4/24/2013 4:05 PM, David Quigley wrote:
> > On 04/24/2013 19:03, J. Bruce Fields wrote:
> >> On Wed, Apr 24, 2013 at 06:14:16PM -0400, David Quigley wrote:
> >>> On 04/24/2013 18:12, Steve Dickson wrote:
> >>> >On 24/04/13 18:02, J. Bruce Fields wrote:
> >>> >>n Wed, Apr 24, 2013 at 04:17:50PM -0400, Steve Dickson wrote:
> >>> >>>> From: David Quigley <dpquigl@davequigley.com>
> >>> >>>>
> >>> >>>> There is a time where we need to calculate a context without the
> >>> >>>> inode having been created yet. To do this we take the
> >>> >>>negative dentry and
> >>> >>>> calculate a context based on the process and the parent
> >>> >>>directory contexts.
> >>> >>How can we get review from security/selinux folks?  I can't
> >>> >>apply these
> >>> >>without....
> >>> >Its my understand they have been reviewed a number times... And
> >>> >they have not
> >>> >change since I've working on these patches...
> >>> >
> >>> >steved.
> >>> >--
> >>> >To unsubscribe from this list: send the line "unsubscribe
> >>> >linux-nfs" in
> >>> >the body of a message to majordomo@vger.kernel.org
> >>> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>
> >>> That is correct. They have been acked in the past and haven't
> >>> changed at all since then.
> 
> For the record, I haven't ACKed because I have been unable to
> get the NFS labeling to work with Smack. I also note that I
> am not NAKing, either, as I have not had the time to determine
> what's wrong. I do know that the ideas floated at the time turned
> out to not be the problem. Hopefully I'll have time to look
> into this sometime.

OK, we'll add an:

neither-acked-nor-nacked-by: Casey Schaufler <casey@schaufler-ca.com>

--b.
