Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36111 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753060Ab1FIRSN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jun 2011 13:18:13 -0400
Message-ID: <4DF10053.9050901@RedHat.com>
Date: Thu, 09 Jun 2011 13:18:11 -0400
From: Steve Dickson <SteveD@redhat.com>
To: greearb@candelatech.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfs-utils:  Support binding to source address.
References: <1307574083-27608-1-git-send-email-greearb@candelatech.com>
In-Reply-To: <1307574083-27608-1-git-send-email-greearb@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,


On 06/08/2011 07:01 PM, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
> 
> This lets one specify the source IP address for
> sockets, allowing users to leverage routing rules
> on multi-homed systems.
Right out of the box I do think some support like 
this would be good... but I not convinced on how needed
something like this is which means there is a lot of 
change here for basically not... But lets continue 
to talk about to see where we end up.... 

One thing you must do is break up this patch in to
a more readable patch series. There is no way I going
to commit a patch that is close to 1500 lines
that so invasive. 

Here is how I create patch series. 

git pull devel-tree
git checkout -b devel-branch

make changes
git commit -s -a 
make more changes 
git commit -s -a 
[Note, each one of the commits (or patches) have to be stand-alone patches ]
[Which means after each commit the tree has to compile and be functional   ]

When all the changes are done, create the patches like:

git format-patch -n -o /tmp/sumbit --cover-letter  commit1^..commitN

edit /tmp/summit/*cover* to explain your changes

Then post the patches with git send-email command:

git send-email $DRYRUN  --suppress-cc=all --suppress-from --no-chain-reply-to --from "Your Name <emailaddress@foobar.com>" --to Linux NFS Mailing list <linux-nfs@vger.kernel.org>" --smtp-server smtp.foobar.com /tmp/submit/*.patch

Note, I'm not sure the --smtp argument is needed... but it works..

steved.
