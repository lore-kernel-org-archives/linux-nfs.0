From: =?iso-8859-1?Q?Thomas_Lang=E5s?= <tlan@stud.ntnu.no>
Subject: Re: e1000 intel driver bug (which impacts nfs)
Date: Mon, 3 Jun 2002 00:28:19 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020603002819.A5501@stud.ntnu.no>
References: <Pine.OSF.4.20.0205262256430.16951-100000@azure.dstc.edu.au>
Reply-To: nfs@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from due.stud.ntnu.no ([129.241.56.71])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Edpo-0003Fr-00
	for <nfs@lists.sourceforge.net>; Sun, 02 Jun 2002 15:28:24 -0700
To: jason andrade <jason@dstc.edu.au>
In-Reply-To: <Pine.OSF.4.20.0205262256430.16951-100000@azure.dstc.edu.au>; from jason@dstc.edu.au on Sun, May 26, 2002 at 11:06:06PM +1000
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

jason andrade:
> I hope this helps anyone else trying to debug mysterious "nfs hangs" under
> 2.4.X.  It doesn't seem to be tickled unless you are doing quite large
> amounts of nfs traffic (we're pushing 1-1.5T a day on this interface)
> and it's quite random (i've had a lockup from 4 hours to 10 days after
> a reboot)

We've also got problems with nfs-hangs when transfering large files (ie.
files around 300-400M, sometime we have to go a bit higher tho, like
2GB-3GB files, but it's always possible to trigger this. However, we
don't need to be jumping through hoops to "fix it", after a min or so,
it's ok again. It seems to me like there's a VM problem or something.

We've got 2GB mem on the machines which are suffering from theese 
problems.

-- 
Thomas

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
