From: Rudi Starcevic <tech@wildcash.com>
Subject: Rpc.statd max threads
Date: Wed, 06 Apr 2005 12:57:50 -0700
Message-ID: <42543F3E.1080300@wildcash.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJ0kJ-00060S-Tm
	for nfs@lists.sourceforge.net; Tue, 05 Apr 2005 19:58:23 -0700
Received: from hummer.onthenet.com.au ([203.13.68.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJ0kJ-0001ko-Cm
	for nfs@lists.sourceforge.net; Tue, 05 Apr 2005 19:58:23 -0700
Received: from [192.168.2.24] (imp3.dsl.onthenet.net [203.144.21.139])
	by hummer.onthenet.com.au (Postfix) with ESMTP id DDF6419FB1B
	for <nfs@lists.sourceforge.net>; Wed,  6 Apr 2005 12:58:17 +1000 (EST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hi,

I'm using a FreeBSD NFS server with Linux NFS clients.

I am having trouble finding how to set the minimum or maximum or default 
client connection threads.

I can increase my nfsd on FreeBSD to 20 and would like now to up the 
clients on Linux.

Man rpc.statd doesn't seem to show me how.
Can you please help?


This is the output from man rpc.statd on my Debian Linux box

-F    
By  default,  rpc.statd  forks  and puts itself in the background when 
started. The -F argument tells it to
remain in the foreground. This option is mainly for debugging purposes.

-d    
By default, rpc.statd sends logging messages via syslog(3) to system 
log.  The -d argument forces it to log
verbose  output  to  stderr  instead. This option is mainly for 
debugging purposes, and may only be used in
conjunction with the -F parameter.

-n, --name name
specify a name for rpc.statd to use as the local hostname. By default, 
rpc.statd will  call  gethostname(2)
to get the local hostname. Specifying a local hostname may be useful for 
machines with more than one inter-faces.

-o, --outgoing-port port
specify a port for rpc.statd to send outgoing  status  requests  from.   
By  default,  rpc.statd  will  ask
portmap(8)  to  assign  it  a  port  number.   As of this writing, there 
is not a standard port number that
portmap always or usually assigns.  Specifying a port may be useful when 
implementing a firewall.

-p, --port port
specify a port for rpc.statd to listen on.  By default, rpc.statd will 
ask portmap(8) to assign it  a  port
number.   As  of  this writing, there is not a standard port number that 
portmap always or usually assigns.
Specifying a port may be useful when implementing a firewall.

-P, --state-directory-path directory
specify a directory in which to place statd state information.  If this 
option is not specified the default
of /var/lib/nfs is used.

 -N    
Causes  statd  to  run in the notify-only mode. When started in this 
mode, the statd program will check its
state directory, send notifications to any monitored nodes, and exit 
once the notifications have been sent.
This mode is used to enable Highly Available NFS implementations (i.e. 
HA-NFS).

-?     Causes rpc.statd to print out command-line help and exit.

-V     Causes rpc.statd to print out version information and exit.

Thank you.
Regards,
Rudi





-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
