From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Problem with permissions
Date: Thu, 18 Apr 2002 16:46:31 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15550.27591.650445.471426@notabene.cse.unsw.edu.au>
References: <5.1.0.14.2.20020418115542.058a25a0@pop.cs.curtin.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16y5d7-0002of-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Apr 2002 23:42:53 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <dave@cs.curtin.edu.au>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Thu, 18 Apr 2002 16:42:45 +1000
To: David Shirley <dave@cs.curtin.edu.au>
In-Reply-To: message from David Shirley on Thursday April 18
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

On Thursday April 18, dave@cs.curtin.edu.au wrote:
> Hi All,
> 
> We have a NFSV3 server (UDP) and NFSV3 clients. Now
> when the permissions on a file are say rwx-----x
> ie world executable, then none owners and non group
> members can read the file as well as execute it?
> 
> This shouldn't be the case?
> 
> Are there any switches or anything on the server that
> I need to configure?
> 

I believe that this is a client issue (though it could possibly be a
server issue).

The server has to allow the client computer to read such a file so
that it can then execute it.  However the client computer should
restrict client applications to only using "exec" on the file, not
"open". 

When an application asks for an open(READ), the client should send an
ACCESS3 request to the server asking if that user has READ access.
The server will say "no" (at least the code looks like it should) and
the client should honour that.

What client OS are you using?
I seem to recall that there was a time when the Linux NFS client
didn't use ACCESS requests, but I think that has been fixed (but Trond
could say for sure).

It is all rather academic really.  If you want to read a file that is
executable but not readable, you just execute it under ptrace control
and suck out whatever you want from the process.


NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
