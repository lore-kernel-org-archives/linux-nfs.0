From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Fri, 2 May 2008 17:13:33 -0400
Message-ID: <24c1515f0805021413u450d8bbcr806a90c327b287a1@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <20080418203225.GD28277@fieldses.org>
	 <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>
	 <20080421000214.GA5453@fieldses.org>
	 <24c1515f0804281352u2d04ac89i820dc6807dde39f1@mail.gmail.com>
	 <4817346F.5000101@netapp.com> <20080429161607.GA20420@fieldses.org>
	 <24c1515f0805010557o5daf72f7hc3db5bf85354898e@mail.gmail.com>
	 <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com>
	 <481B316E.8090800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "Wendy Cheng" <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:55980 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932556AbYEBVNe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2008 17:13:34 -0400
Received: by rv-out-0506.google.com with SMTP id l9so212576rvb.1
        for <linux-nfs@vger.kernel.org>; Fri, 02 May 2008 14:13:33 -0700 (PDT)
In-Reply-To: <481B316E.8090800@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 2, 2008 at 11:21 AM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:

>  After browsing thru "statd -n" flow, it is still not clear what will happen
> if there are more than 2 interfaces used to export NFS shares ?

How come? It will use the interface specified with -n.


>  Using "statd -H", together with patches described in:
>  https://www.redhat.com/archives/cluster-devel/2007-April/msg00028.html ,

So this basically makes it a users problem, I don't
like it. Statd's standard notifications are just fine and
I don't want to have anything to do with the process.
It should work as is, out of the box, without writing
separate programs to handle stuff that statd doesn't
do.


>  our cluster failover (with 4 IP interfaces per server) seemed to run well
> without troubles.

Your idea was to serve traffic via all of these interfaces?
One specific segment is just enough for us. Our servers
can have anything from 5 - 100 floating addresses and
it would be just great if we could keep each service
bound in it's own address. It's just better that way.


> Note that 2/3 of the patch in 4-3 can be removed *now*
> since it deals with moving server address from network header into lockd
> internal structures - another similar patch (by Frank van Maarseveen) was
> accepted into mainline kernel after our patch that has the required
> functionality:
>  http://lkml.org/lkml/2007/7/10/553 .
>
>  So the following is our (-H) flow:
>  * Server dispatches statd with "-N" option that has a user mode script
>   (sample program fotest.c enclosed). It is expected the user mode script
>   could structure its nlm directory accordingly.
>  * Upon failover, the take-over server notifies clients with:
>   "/usr/sbin/sm-notify -f -v floating_ip_address -P an_sm_directory"
>
>  The advantages of "-H" approach over "-n" are (I think ?):
>  * It can handle multiple NFS export network interfaces.
>  * It knows which clients coming from which interfaces to allow selective
> grace period for each interface.
>
>  In many ways, I would think "-n" should be obsolete ?

To me these use cases are clearly different. You're
trying to serve traffic to multiple segments and need
stuff that 'user have to worry about' to accomplish
this.  -n works as is for just one segment. And how
many users really need interface specific selective
grace anyway?


-- 
// Janne
