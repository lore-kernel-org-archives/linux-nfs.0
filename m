From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 16:33:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040423143308.GW3491@suse.de>
References: <40892507.2030004@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH1kB-00010v-NY
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 07:33:31 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BH1kB-0006Jn-8x
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 07:33:31 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <40892507.2030004@RedHat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, Apr 23, 2004 at 10:15:35AM -0400, Steve Dickson wrote:
> Here is a 2.4 patch that will reinstantiate an inode
> when a ESTALE error is returned on a getattr. When
> the error occurs, a lookup is immediately issued
> to get a new fh.

Brrr. Are you sure this is such a good idea?  It will have all sorts of
bad side effects. For instance, you may be writing a file named "foo".
Someone else replaces foo with their copy (mv foo-new foo) and your file
handle becomes stale.

If you issue a lookup immediately, you will continue writing, but
now your writes go to the new file and produce garbage.

At a minimum, the lookup should occur at file open, and only if
there are no other users of the inode.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
