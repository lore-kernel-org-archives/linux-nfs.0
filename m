From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: input/output error
Date: 07 Mar 2003 18:00:34 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs65qv6ril.fsf@charged.uio.no>
References: <1047055047.30015.18.camel@batman.ece.rice.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Brent Clements <bclem@rice.edu>
In-Reply-To: <1047055047.30015.18.camel@batman.ece.rice.edu>
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

>>>>> " " == Brent Clements <bclem@rice.edu> write

     > rtcfiler:/users/users /users nfs
     > rw,v3,rsize=32768,wsize=32768,soft,udp,lock,addr=rtcfiler 0 0
                                     ^^^^

Read up on the 'soft' mount option in 'man 5 nfs'.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
