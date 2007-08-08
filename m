From: "Kottaridis, Chris" <chris.kottaridis@windriver.com>
Subject: Re: rpc.mountd memory leak
Date: Wed, 8 Aug 2007 13:30:12 -0700
Message-ID: <37B62E0F71C9E14B9859FADB1FC3E3E14EB158@ala-mail02.corp.ad.wrs.com>
References: <20070808162009.2e7f6556.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIsAZ-0002bQ-GX
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 13:30:15 -0700
Received: from mail.windriver.com ([147.11.1.11] helo=mail.wrs.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IIsAd-0003wh-Fi
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 13:30:19 -0700
In-Reply-To: <20070808162009.2e7f6556.jlayton@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

>get_hostent() uses xmalloc() which should make the program die if it
fails. So checking for
>he == NULL really isn't needed. 

True in 1.1.0, I should have looked there first! Not in 1.0.7.

Again Thanks for the info

Chris Kottaridis
Senior Engineer
Wind River Systems
719-522-9786

-----Original Message-----
From: Jeff Layton [mailto:jlayton@redhat.com] 
Sent: Wednesday, August 08, 2007 2:20 PM
To: Kottaridis, Chris
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] rpc.mountd memory leak

On Wed, 8 Aug 2007 13:13:51 -0700
"Kottaridis, Chris" <chris.kottaridis@windriver.com> wrote:

> Thanks.
> 
> Also, it seems possible for get_hostent() to return a NULL value if 
> the malloc fails. The client_check() doesn't perform any kind of 
> sanity check on it's second parameter, the 'he' variable of
client_compose().
> So, there is the possibility that client_check() can try and derefence

> a NULL pointer.
> 
> In other locations in the code where get_reliable_hostbyaddr() or
> get_hostent() is called a sanity check for NULL is done to make sure 
> the value isn't NULL. For example in auth_authenticate():
> 
>         hp = get_reliable_hostbyaddr((const char*)&caller->sin_addr, 
> sizeof(struct in_addr),
>                                      AF_INET);
>         if (!hp)
>                 hp = get_hostent((const char*)&caller->sin_addr, 
> sizeof(struct in_addr),
>                                      AF_INET);
>         if (!hp)
>                 return exp;
> 
> Should there be a similar check on 'he' in client_compose to prevent a

> NULL pointer dereference in client_check() ? Something like:
> 
>         if (clientlist[MCL_WILDCARD] || clientlist[MCL_NETGROUP])
>                 he = get_reliable_hostbyaddr((const char*)&addr, 
> sizeof(addr), AF_INET);
>         if (he == NULL)
>                 he = get_hostent((const char*)&addr, sizeof(addr), 
> AF_INET);
> 
> 	  if (he == NULL)
> 		return name;
> 
> Seems like a more graceful way to handle a malloc failure in 
> get_hostent().
> 
> Thanks
> 

get_hostent() uses xmalloc() which should make the program die if it
fails. So checking for he == NULL really isn't needed.

--
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
