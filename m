From: Greg Lindahl <lindahl@keyresearch.com>
Subject: Re: Soft vs Hard mounts
Date: Fri, 16 May 2003 14:50:18 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030516215018.GB1879@greglaptop.internal.keyresearch.com>
References: <482A3FA0050D21419C269D13989C61131274DD@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
To: nfs@sourceforge.net
In-Reply-To: <482A3FA0050D21419C269D13989C61131274DD@lavender-fe.eng.netapp.com>
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

On Fri, May 16, 2003 at 09:13:18AM -0700, Lever, Charles wrote:

> recently trond mentioned that this issue was not likely to
> be addressed until after 2.6 because it requires architectural
> changes in the VFS layer and probably a new type of semaphor
> implementation.

Well, some of the issues might be separate, and some have workarounds.

For example, if stat() on a nfs mountpoint causes a process to hang,
and you have processes like ssh which want to make sure your conf file
is secure by walking the path back to /, there is a workaround
of putting each mount point in its own directory:

/home/foo/foo
/home/bar/bar

You'd also want to look into what the Linux automounter does. It
looks different from what I'm used to.

> 3.  make soft mounts work more reliably by purging a file's
>     page cache contents when a soft timeout occurs
> 
> 4.  educate sysadmins how to make soft mounts more reliable
>     by thoroughly testing to determine a reasonable set of
>     mount options.

Option (3) might make network congestion much worse, and turn
congestion into failure. (4) is really hard, because it's hard to
thoroughly test many different types of activity and congestion.

Distributed system people generally eventually end up thinking that
introducing any timeout will always result in congestion and odd
circumstances turning into failures. I vastly prefer systems which
have the behavior of "hard,intr".

greg



-------------------------------------------------------
This SF.net email is sponsored by: If flattening out C++ or Java
code to make your application fit in a relational database is painful, 
don't do it! Check out ObjectStore. Now part of Progress Software.
http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
