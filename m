From: Greg Lindahl <lindahl@keyresearch.com>
Subject: Re: Re: NFS retry on disconnection
Date: Mon, 13 May 2002 14:04:01 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020513140401.A2381@wumpus.keyresearch.com>
References: <OFAE43C5AB.44E1A1F2-ON87256BB8.00590C28@boulder.ibm.com> <200205131953.g4DJr0f30734@buggy.badula.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nixon.xkey.com ([209.245.148.124])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177Mys-00050F-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 14:03:43 -0700
Received: (from lindahl@localhost)
	by localhost.conservativecomputer.com (8.11.6/8.11.0) id g4DL41R02386
	for nfs@lists.sourceforge.net; Mon, 13 May 2002 14:04:01 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <200205131953.g4DJr0f30734@buggy.badula.org>; from ionut@cs.columbia.edu on Mon, May 13, 2002 at 03:53:00PM -0400
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

On Mon, May 13, 2002 at 03:53:00PM -0400, Ion Badulescu wrote:

> > Though you didn't answer the question, your advice implies that the Linux
> > NFSv3 filesystem driver retries forever when communication with the NFS
> > server has been lost.  If not, please correct us.
> 
> The default is 'hard' which will retry forever.
> 
> You can mount with '-o soft' which will give you the desired data corruption.

Linux NFS isn't any different from any other OS in this treatment of
"soft" and "hard", although I guess an OS could have a default to
"soft", which would be a bad idea.

"Best practices" is to mount "hard,intr" so the user can interrupt the
process if they wish to... otherwise it will wait until the problem is
fixed. You should also use automounts to ensure that a minimum number
of filesystems are mounted, especially if you have a complicated setup
with many infrequently-used filesystems.

greg


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
