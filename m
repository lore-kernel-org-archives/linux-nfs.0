Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:48994 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327Ab1FJQoq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 12:44:46 -0400
Message-ID: <4DF249F6.20301@panasas.com>
Date: Fri, 10 Jun 2011 09:44:38 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: tao.peng@emc.com, bergwolf@gmail.com, rees@umich.edu,
        linux-nfs@vger.kernel.org, honey@citi.umich.edu
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
References: <cover.1307464381.git.rees@umich.edu> <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu> <4DEED80A.4000102@panasas.com> <20110608021852.GA20998@merit.edu> <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com> <4DF062D6.7010304@panasas.com> <BANLkTi=SMQhUNHEy=-ZPqFtCgKcnCtks=w@mail.gmail.com> <4DF13B65.5030401@panasas.com> <F19688880B763E40B28B2B462677FBF805BED9D222@MX09A.corp.emc.com> <4DF21267.9060706@panasas.com> <4DF2450A.6000704@panasas.com>
In-Reply-To: <4DF2450A.6000704@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/10/2011 09:23 AM, Boaz Harrosh wrote:
> 
> I disagree. Please make that same exact patch for the server you are using!
> 
> Leave the client alone. Don't even consider getting use to this, sticking
> broken stuff on client scripts. If anywhere it should be in Server configuration
> files
> 
> Boaz
> 

BTW the algorithm at the *server* side need not be dynamic and can be very simple.
Just a simple rule based:

1. If the file is new/zero-size just give out a small layout say 1-2 stripe_units
2. If the file is or becoming bigger give out some BIG maximal optimum IO size.
   A size that anything bigger will not increase performance.

3. If the file is opened by a second client, recall the first big layout and
   give out a one-to-few strips layout for shared access.
   You will find that this shared file case is very rare. There are not many
   application that share the same file. If they do they usually use range
   locks. Query your lock manager if the client has a lock on this range of
   the file, give out the full locked range as a layout. If that is not the proper
   hint from the application, then what is? It is a much better hint then the
   nfs-client can ever guess.

4. Make it simple as hell....

Just my $0.017
Boaz
