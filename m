Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:37803 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242Ab3EPNz0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 May 2013 09:55:26 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH 0/3] Speed up detection of whether or not rpc.gssd is running
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1368647441-24815-1-git-send-email-Trond.Myklebust@netapp.com>
Date: Thu, 16 May 2013 09:55:21 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <14F7EF8E-A5C7-4187-B53A-EA71283AFC3A@oracle.com>
References: <1368647441-24815-1-git-send-email-Trond.Myklebust@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 15, 2013, at 3:50 PM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> Also fix the auth_gss pipe version detection so that it works correctly
> in the presence of namespaces.

Obviously my preference is to keep the existing krb5i -> sys logic and to try to address the upcall timeout, so this is a good direction, IMO.

After some review, I'm still a little concerned about initialization races inappropriately preventing upcalls, but time (and testing) will tell.  I'm happy with this solution if you and Bruce are.

Speaking of testing, I can test this series if you think that would be valuable, but I assume that those who originally reported the timeout problem (Jeff and Steve) should be the ones to confirm whether this series addresses their concern.


> Trond Myklebust (3):
>  SUNRPC: Fix a bug in gss_create_upcall
>  SUNRPC: Faster detection if gssd is actually running
>  SUNRPC: Convert auth_gss pipe detection to work in namespaces
> 
> net/sunrpc/auth_gss/auth_gss.c | 62 ++++++++++++++++++++++++++++--------------
> net/sunrpc/netns.h             |  4 +++
> net/sunrpc/rpc_pipe.c          |  5 ++++
> 3 files changed, 50 insertions(+), 21 deletions(-)

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




