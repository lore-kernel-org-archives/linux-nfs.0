From: "bruce" <bedouglas@earthlink.net>
Subject: installing nfs on rh8.0 using iptables...
Date: Fri, 2 Jul 2004 11:12:04 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <034001c46060$15045970$0301a8c0@Mesa.com>
Reply-To: <bedouglas@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BgSRH-0005BI-PA
	for nfs@lists.sourceforge.net; Fri, 02 Jul 2004 11:07:07 -0700
Received: from rwcrmhc12.comcast.net ([216.148.227.85])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BgSRH-0006tq-Db
	for nfs@lists.sourceforge.net; Fri, 02 Jul 2004 11:07:07 -0700
To: <nfs@lists.sourceforge.net>
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

hi...

i'm starting to install nfs on a rh8.0 box. i want to have iptables
configured to allow the nfs traffic to pass through from client to server...

i have some questions/issues....

i can reboot my box that i'm using as an nfs server... the appropriate
processes appear to be running. however, i'm having an issue with iptables.

when iptables is running, i'm unable to connect from a client to the nfs
box. i stop iptables, everything works as it should. the various literature
i've seen indicates that nfs requires more than simply the 2049 port.

so my questions:

where do i insert the code/parameters to lock the ports down for the various
processes.

should i be making changes to the /etc/rc.d/init.d/nfs to lock down the
ports for the various processes?????

i've seen the following docs:.
<<<<<<<<<<<<<<<<<<===========================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
The other daemons, statd, mountd, lockd, and rquotad, will normally move
around to the first available port they are informed of by the portmapper.

To force statd to bind to a particular port, use the -p portnum option. To
force statd to respond on a particular port, additionally use the -o portnum
option when starting it.

(ok... but how do i find the process that starts the statd process. is this
the /etc/rc.d/init.d/nfs script?????? )

To force mountd to bind to a particular port use the -p portnum option.

For example, to have statd broadcast of port 32765 and listen on port 32766,
and mountd listen on port 32767, you would type:

# statd -p 32765 -o 32766
# mountd -p 32767


lockd is started by the kernel when it is needed. Therefore you need to pass
module options (if you have it built as a module) or kernel options to force
lockd to listen and respond only on certain ports.

If you are using loadable modules and you would like to specify these
options in your /etc/modules.conf file add a line like this to the file:

options lockd nlm_udpport=32768 nlm_tcpport=32768


The above line would specify the udp and tcp port for lockd to be 32768.

If you are not using loadable modules or if you have compiled lockd into the
kernel instead of building it as a module then you will need to pass it an
option on the kernel boot line.

It should look something like this:

 vmlinuz 3 root=/dev/hda1 lockd.udpport=32768 lockd.tcpport=32768


The port numbers do not have to match but it would simply add unnecessary
confusion if they didn't.
<<<<<<<<<<<<<<<<<<===========================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

my copy of the /etc.../nfs script doesn't have "statd"... should i add it???
i have rh8.0. also, how do i know if i'm using "loadable modules", or if the
kernel had lockd compiled... and if i do need to pass the options in as boot
parameters, where/how would i do this... what file would i have to
edit...?????

finally, after i've gotten this to work, asuming i get this far! i still
have to face the issue of setting up the iptables to correctly handle the
ports....

any thoughts/comments on these issues... any help/assistance would be
helpful, and greatly appreciated!!!!!!

thanks

-bruce



-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
