From: Brian Pontz <axehind007@yahoo.com>
Subject: Re: bash-2.05b$ touch foo
Date: Thu, 7 Aug 2003 16:00:39 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030807230039.73452.qmail@web14405.mail.yahoo.com>
References: <20030807224852.GA810@quasar.nro.au.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web14405.mail.yahoo.com ([216.136.174.62])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ktkN-0002Jk-00
	for <nfs@lists.sourceforge.net>; Thu, 07 Aug 2003 16:00:39 -0700
To: Lawrence Ong <lawrence.ong@netregistry.com.au>
In-Reply-To: <20030807224852.GA810@quasar.nro.au.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Thanks for the reply.

That wouldnt work for me. Different users will be
creating files on the nfs mount and there are many
files already there. So I couldnt do a chown -R type
of solution either.

But it does bring up something else I noticed. root
doesnt have the mentioned problem.

Thanks,
Brian

--- Lawrence Ong <lawrence.ong@netregistry.com.au>
wrote:
> Try creating it as root and chown it to that user
> 
> Cheers,
> Lawrence


__________________________________
Do you Yahoo!?
Yahoo! SiteBuilder - Free, easy-to-use web site design software
http://sitebuilder.yahoo.com


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
