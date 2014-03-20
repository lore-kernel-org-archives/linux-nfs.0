Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40811 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757116AbaCTNtM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Mar 2014 09:49:12 -0400
Message-ID: <532AF1D1.7070400@RedHat.com>
Date: Thu, 20 Mar 2014 09:49:05 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Noam Meltzer <noam@primarydata.com>, Simo Sorce <simo@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        sssd-devel <sssd-devel@lists.fedorahosted.org>
Subject: Re: [PATCH v2 0/5] NFSv4 rpc.idmapd plugin
References: <1393918676-20865-1-git-send-email-noam@primarydata.com>	<5321CDB6.7010803@RedHat.com>	<1394729939.32465.231.camel@willson.li.ssimo.org>	<20140313172531.GA7124@fieldses.org>	<1394732462.32465.235.camel@willson.li.ssimo.org> <CAOoFWK_uNLEim7MH=K=Ojge_KjcJk6V7p1-LFcYNPC9=fZ90fQ@mail.gmail.com>
In-Reply-To: <CAOoFWK_uNLEim7MH=K=Ojge_KjcJk6V7p1-LFcYNPC9=fZ90fQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/20/2014 03:33 AM, Noam Meltzer wrote:
> 
> 
> 
> On Thu, Mar 13, 2014 at 7:41 PM, Simo Sorce <simo@redhat.com <mailto:simo@redhat.com>> wrote:
> 
>     On Thu, 2014-03-13 at 13:25 -0400, J. Bruce Fields wrote:
>     > On Thu, Mar 13, 2014 at 12:58:59PM -0400, Simo Sorce wrote:
>     > > On Thu, 2014-03-13 at 11:24 -0400, Steve Dickson wrote:
>     > >
>     > > > V4 servers now have an option of returning a uid string (aka "3606")
>     > > > where the NFS client just converts that into the uid.
>     > >
>     > > Can the client tell the server *not to do that* ?
>     >
>     > The client can use kerberos, in which case the server won't do that.
> 
>     This is sufficient, thanks.
> 
>     > Other than that, no, the behavior can only be controlled by server-side
>     > configuration.
> 
>     A little sub-optimal if the server can do either but the client can have
>     a choice, but ok.
> 
> 
> Sorry for the late response. A misplaced email filtering rule had moved it away from my inbox.
> How can we push this forward?
> 
Not sure since I don't maintain any of the code these patches change... 

steved.
 
