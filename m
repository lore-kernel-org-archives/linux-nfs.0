From: Matthew Mitchell <matthew@geodev.com>
Subject: Re: mmap() and NFS server performance
Date: Mon, 16 Dec 2002 08:33:57 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DFDE455.1000004@geodev.com>
References: <3DFA4C9A.50101@geodev.com> <shsadj826bt.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gateway2.geodev.com ([64.45.165.170] ident=[T2juuA0aXVR4tjY/ellAZwwHtC0/xFq+])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18NwNo-00052n-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 06:38:12 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

Trond Myklebust wrote:
>>>>>>" " == Matthew Mitchell <matthew@geodev.com> writes:
>>>>>
> 
>      > values.  These apps were originally written on Solaris with
>      > Solaris NFS servers assumed to be the data source; the Sun guys
>      > said that mmap would be much faster than read/write and they
>      > were correct.  However, now that we have a few Linux NFS
>      > servers, we're seeing the opposite.
> 
> As long as the clients are still Solaris, then the only difference can
> be the network, and the server performance.
> 
> Of the 2, the bigger 'generic' troublemaker tends to be the network.
> Solaris clients always tend to prefer NFS over TCP since that tends to
> be more reliable on poor networks than does UDP. Unfortunately, NFS
> over TCP on the server side is a fairly recent addition to Linux: it
> only just made it into the stable release 2 weeks ago (when 2.4.20 was
> released). To the best of my knowledge, none of the RedHat kernels
> support it yet.

For some reason it had not occurred to me that the NFS server on the 
Linux box might be using UDP instead of TCP; I had it in my head somehow 
that it would use TCP.  Obviously it wasn't.  Now, we had noticed slower 
speeds with UDP before (when Linux clients were using UDP to access the 
Solaris servers).  Could this be causing such a drastic slowdown?

I have looked at some network packet streams and I don't think we are 
having any of the classic UDP problems -- negligible # of retransmits, 
most packets arrive in order.  The Linux server isn't loaded hardly at all.

Three further questions:

1) What would you like to see, tcpdump/snoop wise, to verify this?

2) Could UDP service really be causing this order of magnitude slowdown?

3) Is TCP server code "ready enough" for production use?  In our case we 
don't mind some occasional bugs, but it needs to be able to stay working 
under reasonable load for a day or so at a time for us to get anything 
done ("Stale NFS file handle" is a scourge...).

Thanks again.

-- 
Matthew Mitchell
Systems Programmer/Administrator            matthew@geodev.com
Geophysical Development Corporation         phone 713 782 1234
1 Riverway Suite 2100, Houston, TX  77056     fax 713 782 1829



-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
