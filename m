Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:31062 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968Ab3KOQ4x convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 11:56:53 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "neilb@suse.de" <neilb@suse.de>,
        "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 1/3] sunrpc: create a new dummy pipe for gssd to hold
 open
Date: Fri, 15 Nov 2013 16:56:51 +0000
Message-ID: <1384534611.4046.8.camel@leira.trondhjem.org>
References: <1384431919-20921-1-git-send-email-jlayton@redhat.com>
	 <1384431919-20921-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384431919-20921-2-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-11-14 at 07:25 -0500, Jeff Layton wrote:
+AD4- rpc.gssd will naturally hold open any pipe named +ACo-/clnt+ACo-/gssd that shows
+AD4- up under rpc+AF8-pipefs. That behavior gives us a reliable mechanism to tell
+AD4- whether it's actually running or not.
+AD4- 
+AD4- Create a new toplevel +ACI-gssd+ACI- directory in rpc+AF8-pipefs when it's mounted.
+AD4- Under that directory create another directory called +ACI-clntXX+ACI-, and then
+AD4- within that a pipe called +ACI-gssd+ACI-.
+AD4- 
+AD4- We'll never send an upcall along that pipe, and any downcall written to
+AD4- it will just return -EINVAL.
+AD4- 
+AD4- Signed-off-by: Jeff Layton +ADw-jlayton+AEA-redhat.com+AD4-

Hi Jeff,

Don't you need something in rpc+AF8-kill+AF8-sb() in order to remove the pipe
and the clntXX directory?

Also please see rpc+AF8-mkdir+AF8-populate() and rpc+AF8-mkdir+AF8-depopulate() for how
you can simplify the creation/destruction of the clntXX+-clntXX/gssd.

Cheers
  Trond
