From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: nfs-utils 1.0.5 break amd?
Date: 04 Aug 2003 18:29:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1060014597.2980.56.camel@ikarus>
References: <200308041605.h74G5uRc003894@buggy.badula.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jiDi-0003N8-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Aug 2003 09:30:03 -0700
To: Ion Badulescu <ionut@badula.org>
In-Reply-To: <200308041605.h74G5uRc003894@buggy.badula.org>
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

On Mon, 2003-08-04 at 18:05, Ion Badulescu wrote:
> On 31 Jul 2003 19:32:22 +0200, Marc Schmitt <mschmitt@inf.ethz.ch> wrote:
> 
> > After upgrading a RedHat 7.3 box with kernel 2.4.18-27.7xsmp from
> > nfs-utils 1.0.3 to 1.0.5, amd stopped working.
> > 
> > On the client (am-utils-6.0.7-4, nfs-utils-0.3.3-6.73), I issue:
> > 
> > ls /net/<fileserver>
> > 
> > With 1.0.3, I get the correct directory listing under /net/<fileserver>
> > 
> > With 1.0.5, I get:
> > ls: /net/<fileserver>: Input/output error
> 
> Can you mount any shares from <fileserver> by hand, using mount? If not, 
> as I suspect, then the problem is not amd.

Yes, the machine is currently in production (home and project
directories) and has 174 exports, all of them work (otherwhise I'd have
heard something from my users :).

The client I run 'ls /net/<fileserver>' on has access to 3 of the
exported directories, which used to get mounted with nfs-utils 1.0.3.

I'll try to find more debug infos tonight.

Greetz
    Marc



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
