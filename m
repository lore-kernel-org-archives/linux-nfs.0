From: Tavis Barr <tb62@columbia.edu>
Subject: NFS-HOWTO
Date: 15 Mar 2002 21:30:11 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1016245811.1540.14.camel@vaio>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-DzUZBAgzdIo18XiQgRt5"
Received: from pool-151-203-17-82.bos.east.verizon.net ([151.203.17.82] helo=localhost.localdomain)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16m3xb-0000Us-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Mar 2002 18:30:19 -0800
To: nfs@lists.sourceforge.net
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


--=-DzUZBAgzdIo18XiQgRt5
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Attached is a draft of the latest NFS-HOWTO, in HTML format.  (Put it
all in the same directory and go to index.html).  Comments welcome.


Cheers,
Tavis



-- 
---------------------------------------------------------

Tavis Barr                          ,-~~-.___.        
Assistant Professor of Economics   / |  '     \             
Long Island University            (  )        0               
202 Hoxie Hall                     \_/-, ,----'            
C.W. Post Campus, 720 Northern Blvd.  ====           //
Brookville, NY  11548                 /  \-'~;    /~~~(O)
516-299-2321                         /  __/~|   /       |    
tavis.barr@liu.edu                 =(  _____| (_________|

---------------------------------------------------------

--=-DzUZBAgzdIo18XiQgRt5
Content-Disposition: attachment; filename=index.html
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html; charset=ISO-8859-1

<HTML
><HEAD
><TITLE
>Linux NFS-HOWTO</TITLE
><META
NAME=3D"GENERATOR"
CONTENT=3D"Modular DocBook HTML Stylesheet Version 1.64
"><LINK
REL=3D"NEXT"
TITLE=3D"Preamble"
HREF=3D"preamble.html"></HEAD
><BODY
CLASS=3D"ARTICLE"
BGCOLOR=3D"#FFFFFF"
TEXT=3D"#000000"
LINK=3D"#0000FF"
VLINK=3D"#840084"
ALINK=3D"#0000FF"
><DIV
CLASS=3D"ARTICLE"
><DIV
CLASS=3D"TITLEPAGE"
><H1
CLASS=3D"TITLE"
><A
NAME=3D"AEN2"
>Linux NFS-HOWTO</A
></H1
><H3
CLASS=3D"AUTHOR"
><A
NAME=3D"AEN4"
>Tavis Barr</A
></H3
><DIV
CLASS=3D"AFFILIATION"
><DIV
CLASS=3D"ADDRESS"
><P
CLASS=3D"ADDRESS"
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tavis dot barr at li=
u dot edu<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</P
></DIV
></DIV
><H3
CLASS=3D"AUTHOR"
><A
NAME=3D"AEN10"
>Nicolai Langfeldt</A
></H3
><DIV
CLASS=3D"AFFILIATION"
><DIV
CLASS=3D"ADDRESS"
><P
CLASS=3D"ADDRESS"
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;janl at linpro dot n=
o<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</P
></DIV
></DIV
><H3
CLASS=3D"AUTHOR"
><A
NAME=3D"AEN16"
>Seth Vidal</A
></H3
><DIV
CLASS=3D"AFFILIATION"
><DIV
CLASS=3D"ADDRESS"
><P
CLASS=3D"ADDRESS"
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;skvidal at phy dot duke do=
t edu<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</P
></DIV
></DIV
><H3
CLASS=3D"AUTHOR"
><A
NAME=3D"AEN22"
>Tom McNeal</A
></H3
><DIV
CLASS=3D"AFFILIATION"
><DIV
CLASS=3D"ADDRESS"
><P
CLASS=3D"ADDRESS"
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;trmcneal at attbi dot com<=
br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</P
></DIV
></DIV
><P
CLASS=3D"PUBDATE"
>2000-12-28<BR></P
><HR></DIV
><DIV
CLASS=3D"TOC"
><DL
><DT
><B
>Table of Contents</B
></DT
><DT
>1. <A
HREF=3D"preamble.html"
>Preamble</A
></DT
><DD
><DL
><DT
>1.1. <A
HREF=3D"preamble.html#LEGAL"
>Legal stuff</A
></DT
><DT
>1.2. <A
HREF=3D"preamble.html#DISCLAIMER"
>Disclaimer</A
></DT
><DT
>1.3. <A
HREF=3D"preamble.html#FEEDBACK"
>Feedback</A
></DT
><DT
>1.4. <A
HREF=3D"preamble.html#TRANSLATION"
>Translation</A
></DT
><DT
>1.5. <A
HREF=3D"preamble.html#DEDICATION"
>Dedication</A
></DT
></DL
></DD
><DT
>2. <A
HREF=3D"intro.html"
>Introduction</A
></DT
><DD
><DL
><DT
>2.1. <A
HREF=3D"intro.html#WHAT"
>What is NFS?</A
></DT
><DT
>2.2. <A
HREF=3D"intro.html#SCOPE"
>What is this HOWTO and what is it not?</A
></DT
><DT
>2.3. <A
HREF=3D"intro.html#KNOWPREREQ"
>Knowledge Pre-Requisites</A
></DT
><DT
>2.4. <A
HREF=3D"intro.html#SWPREREQ"
>Software Pre-Requisites: Kernel Version and nfs-utils</A
></DT
><DT
>2.5. <A
HREF=3D"intro.html#FURTHERHELP"
>Where to get help and further information</A
></DT
></DL
></DD
><DT
>3. <A
HREF=3D"server.html"
>Setting Up an NFS Server</A
></DT
><DD
><DL
><DT
>3.1. <A
HREF=3D"server.html#SERVERINTRO"
>Introduction to the server setup</A
></DT
><DT
>3.2. <A
HREF=3D"server.html#CONFIG"
>Setting up the Configuration Files</A
></DT
><DD
><DL
><DT
>3.2.1. <A
HREF=3D"server.html#EXPORTS"
>/etc/exports</A
></DT
><DT
>3.2.2. <A
HREF=3D"server.html#HOSTS"
>/etc/hosts.allow and /etc/hosts.deny</A
></DT
></DL
></DD
><DT
>3.3. <A
HREF=3D"server.html#SERVICESTART"
>Getting the services started</A
></DT
><DD
><DL
><DT
>3.3.1. <A
HREF=3D"server.html#PREREQ"
>Pre-requisites</A
></DT
><DT
>3.3.2. <A
HREF=3D"server.html#PORTMAPPER"
>Starting the Portmapper</A
></DT
><DT
>3.3.3. <A
HREF=3D"server.html#DAEMONS"
>The Daemons</A
></DT
></DL
></DD
><DT
>3.4. <A
HREF=3D"server.html#VERIFY"
>Verifying that NFS is running</A
></DT
><DT
>3.5. <A
HREF=3D"server.html#LATER"
>Making changes to /etc/exports later on</A
></DT
></DL
></DD
><DT
>4. <A
HREF=3D"client.html"
>Setting up an NFS Client</A
></DT
><DD
><DL
><DT
>4.1. <A
HREF=3D"client.html#REMOTEMOUNT"
>Mounting remote directories</A
></DT
><DT
>4.2. <A
HREF=3D"client.html#BOOT-TIME-NFS"
>Getting NFS File Systems to Be Mounted at Boot Time</A
></DT
><DT
>4.3. <A
HREF=3D"client.html#MOUNTOPTIONS"
>Mount options</A
></DT
><DD
><DL
><DT
>4.3.1. <A
HREF=3D"client.html#SOFT-VS-HARD"
>Soft vs. Hard Mounting</A
></DT
><DT
>4.3.2. <A
HREF=3D"client.html#BLOCKSIZE"
>Setting Block Size to Optimize Transfer Speeds</A
></DT
></DL
></DD
></DL
></DD
><DT
>5. <A
HREF=3D"performance.html"
>Optimizing NFS Performance</A
></DT
><DD
><DL
><DT
>5.1. <A
HREF=3D"performance.html#BLOCKSIZES"
>Setting Block Size to Optimize Transfer Speeds</A
></DT
><DT
>5.2. <A
HREF=3D"performance.html#PACKET-AND-NETWORK"
>Packet Size and Network Drivers</A
></DT
><DT
>5.3. <A
HREF=3D"performance.html#FRAG-OVERFLOW"
>Overflow of Fragmented Packets</A
></DT
><DT
>5.4. <A
HREF=3D"performance.html#NFS-TCP"
>NFS over TCP</A
></DT
><DT
>5.5. <A
HREF=3D"performance.html#TIMEOUT"
>Timeout and Retransmission Values</A
></DT
><DT
>5.6. <A
HREF=3D"performance.html#NFSD-INSTANCE"
>Number of Instances of the NFSD Server Daemon</A
></DT
><DT
>5.7. <A
HREF=3D"performance.html#MEMLIMITS"
>Memory Limits on the Input Queue</A
></DT
><DT
>5.8. <A
HREF=3D"performance.html#AUTONEGOTIATION"
>Turning Off Autonegotiation of NICs and Hubs</A
></DT
><DT
>5.9. <A
HREF=3D"performance.html#SYNC-ASYNC"
>Synchronous vs. Asynchronous Behavior in NFS</A
></DT
><DT
>5.10. <A
HREF=3D"performance.html#NON-NFS-PERFORMANCE"
>Non-NFS-Related Means of Enhancing Server Performance</A
></DT
></DL
></DD
><DT
>6. <A
HREF=3D"security.html"
>Security and NFS</A
></DT
><DD
><DL
><DT
>6.1. <A
HREF=3D"security.html#PORTMAPPER-SECURITY"
>The portmapper</A
></DT
><DT
>6.2. <A
HREF=3D"security.html#SERVER.SECURITY"
>Server security: nfsd and mountd</A
></DT
><DT
>6.3. <A
HREF=3D"security.html#CLIENT.SECURITY"
>Client Security</A
></DT
><DD
><DL
><DT
>6.3.1. <A
HREF=3D"security.html#NOSUID"
>The nosuid mount option</A
></DT
><DT
>6.3.2. <A
HREF=3D"security.html#BROKENSUID"
>The broken_suid mount option</A
></DT
><DT
>6.3.3. <A
HREF=3D"security.html#SECURING-DAEMONS"
>Securing portmapper, rpc.statd, and rpc.lockd on the client</A
></DT
></DL
></DD
><DT
>6.4. <A
HREF=3D"security.html#FIREWALLS"
>NFS and firewalls (ipchains and netfilter)</A
></DT
><DT
>6.5. <A
HREF=3D"security.html#NFS-SSH"
>Tunneling NFS through SSH</A
></DT
><DT
>6.6. <A
HREF=3D"security.html#SUMMARY"
>Summary</A
></DT
></DL
></DD
><DT
>7. <A
HREF=3D"troubleshooting.html"
>Troubleshooting</A
></DT
><DD
><DL
><DT
>7.1. <A
HREF=3D"troubleshooting.html#SYMPTOM1"
>Unable to See Files on a Mounted File System</A
></DT
><DT
>7.2. <A
HREF=3D"troubleshooting.html#SYMPTOM2"
>File requests hang or timeout waiting for access to the file.</A
></DT
><DT
>7.3. <A
HREF=3D"troubleshooting.html#SYMPTOM3"
>Unable to mount a file system</A
></DT
><DT
>7.4. <A
HREF=3D"troubleshooting.html#SYMPTOM4"
>I do not have permission to access files on the mounted volume.</A
></DT
><DT
>7.5. <A
HREF=3D"troubleshooting.html#SYMPTOM5"
>When I transfer really big files, NFS takes over
   all the CPU cycles on the server and it screeches to a halt.</A
></DT
><DT
>7.6. <A
HREF=3D"troubleshooting.html#SYMPTOM6"
>Strange error or log messages</A
></DT
><DT
>7.7. <A
HREF=3D"troubleshooting.html#SYMPTOM7"
>Real permissions don't match what's in <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
>.</A
></DT
><DT
>7.8. <A
HREF=3D"troubleshooting.html#SYMPTOM8"
>Flaky and unreliable behavior</A
></DT
><DT
>7.9. <A
HREF=3D"troubleshooting.html#SYMPTOM9"
>nfsd won't start</A
></DT
><DT
>7.10. <A
HREF=3D"troubleshooting.html#SYMPTOM10"
>File Corruption When Using Multiple Clients</A
></DT
></DL
></DD
><DT
>8. <A
HREF=3D"interop.html"
>Using Linux NFS with Other OSes</A
></DT
><DD
><DL
><DT
>8.1. <A
HREF=3D"interop.html#AIX"
>AIX</A
></DT
><DD
><DL
><DT
>8.1.1. <A
HREF=3D"interop.html#AIXSERVER"
>Linux Clients and AIX Servers</A
></DT
><DT
>8.1.2. <A
HREF=3D"interop.html#AIXCLIENTS"
>AIX clients and Linux Servers</A
></DT
></DL
></DD
><DT
>8.2. <A
HREF=3D"interop.html#BSD"
>BSD</A
></DT
><DD
><DL
><DT
>8.2.1. <A
HREF=3D"interop.html#BSDSERVER"
>BSD servers and Linux clients</A
></DT
><DT
>8.2.2. <A
HREF=3D"interop.html#BSDCLIENT"
>Linux servers and BSD clients</A
></DT
></DL
></DD
><DT
>8.3. <A
HREF=3D"interop.html#TRU64"
>Compaq Tru64 Unix</A
></DT
><DD
><DL
><DT
>8.3.1. <A
HREF=3D"interop.html#TRU64SERVER"
>Tru64 Unix Servers and Linux Clients</A
></DT
><DT
>8.3.2. <A
HREF=3D"interop.html#TRU64CLIENT"
>Linux Servers and Tru64 Unix Clients</A
></DT
></DL
></DD
><DT
>8.4. <A
HREF=3D"interop.html#HPUX"
>HP-UX</A
></DT
><DD
><DL
><DT
>8.4.1. <A
HREF=3D"interop.html#HPUXSERVER"
>HP-UX Servers and Linux Clients</A
></DT
><DT
>8.4.2. <A
HREF=3D"interop.html#HPUXCLIENT"
>Linux Servers and HP-UX Clients</A
></DT
></DL
></DD
><DT
>8.5. <A
HREF=3D"interop.html#IRIX"
>IRIX</A
></DT
><DD
><DL
><DT
>8.5.1. <A
HREF=3D"interop.html#IRIXSERVER"
>IRIX Servers and Linux Clients</A
></DT
><DT
>8.5.2. <A
HREF=3D"interop.html#IRIXCLIENT"
>IRIX clients and Linux servers</A
></DT
></DL
></DD
><DT
>8.6. <A
HREF=3D"interop.html#SOLARIS"
>Solaris</A
></DT
><DD
><DL
><DT
>8.6.1. <A
HREF=3D"interop.html#SOLARISSERVER"
>Solaris Servers</A
></DT
><DT
>8.6.2. <A
HREF=3D"interop.html#SOLARISCLIENT"
>Solaris Clients</A
></DT
></DL
></DD
><DT
>8.7. <A
HREF=3D"interop.html#SUNOS"
>SunOS</A
></DT
><DD
><DL
><DT
>8.7.1. <A
HREF=3D"interop.html#SUNOSSERVER"
>SunOS Servers</A
></DT
><DT
>8.7.2. <A
HREF=3D"interop.html#SUNOSCLIENT"
>SunOS Clients</A
></DT
></DL
></DD
></DL
></DD
></DL
></DIV
></DIV
><DIV
CLASS=3D"NAVFOOTER"
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
>&nbsp;</TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
>&nbsp;</TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
><A
HREF=3D"preamble.html"
>Next</A
></TD
></TR
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
>&nbsp;</TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
>&nbsp;</TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
>Preamble</TD
></TR
></TABLE
></DIV
></BODY
></HTML
>
--=-DzUZBAgzdIo18XiQgRt5
Content-Disposition: attachment; filename=intro.html
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html; charset=ISO-8859-1

<HTML
><HEAD
><TITLE
>Introduction</TITLE
><META
NAME=3D"GENERATOR"
CONTENT=3D"Modular DocBook HTML Stylesheet Version 1.64
"><LINK
REL=3D"HOME"
TITLE=3D"Linux NFS-HOWTO"
HREF=3D"index.html"><LINK
REL=3D"PREVIOUS"
TITLE=3D"Preamble"
HREF=3D"preamble.html"><LINK
REL=3D"NEXT"
TITLE=3D"Setting Up an NFS Server"
HREF=3D"server.html"></HEAD
><BODY
CLASS=3D"SECT1"
BGCOLOR=3D"#FFFFFF"
TEXT=3D"#000000"
LINK=3D"#0000FF"
VLINK=3D"#840084"
ALINK=3D"#0000FF"
><DIV
CLASS=3D"NAVHEADER"
><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TH
COLSPAN=3D"3"
ALIGN=3D"center"
>Linux NFS-HOWTO</TH
></TR
><TR
><TD
WIDTH=3D"10%"
ALIGN=3D"left"
VALIGN=3D"bottom"
><A
HREF=3D"preamble.html"
>Prev</A
></TD
><TD
WIDTH=3D"80%"
ALIGN=3D"center"
VALIGN=3D"bottom"
></TD
><TD
WIDTH=3D"10%"
ALIGN=3D"right"
VALIGN=3D"bottom"
><A
HREF=3D"server.html"
>Next</A
></TD
></TR
></TABLE
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"></DIV
><DIV
CLASS=3D"SECT1"
><H1
CLASS=3D"SECT1"
><A
NAME=3D"INTRO"
>2. Introduction</A
></H1
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"WHAT"
>2.1. What is NFS?</A
></H2
><P
>      The Network File System (NFS) was developed to allow machines=20
      to mount a disk partition on a remote machine as if it were on
      a local hard drive.   This allows for fast, seamless sharing of=20
      files across a network.
    </P
><P
>      It also gives the potential for unwanted people to access your=20
      hard drive over the network (and thereby possibly read your email=20
      and delete all  your files as well as break into your system) if=20
      you set it up incorrectly.  So please read the Security section of=20
      this document carefully if you intend to implement an NFS setup.
    </P
><P
>      There are other systems that provide similar functionality to NFS.
      Samba (<A
HREF=3D"http://www.samba.org"
TARGET=3D"_top"
>http://www.samba.org</A
>)
      provides file services to Windows clients.  The Andrew File
      System from IBM (<A
HREF=3D"http://www.transarc.com/Product/EFS/AFS/index.html"
TARGET=3D"_top"
>http://www.transarc.com/Product/EFS/AFS/index.html</A
>),=20
      recently open-sourced, provides a file sharing mechanism with some=20
      additional security and performance features.  The Coda File System=20
      (<A
HREF=3D"http://www.coda.cs.cmu.edu/"
TARGET=3D"_top"
>http://www.coda.cs.cmu.edu/</A
>) is still in development as of this writing
      but is designed to work well with disconnected clients.  Many of the
      features of the Andrew and Coda file systems are slated for inclusion
      in the next version of NFS (Version 4) (<A
HREF=3D"http://www.nfsv4.org"
TARGET=3D"_top"
>http://www.nfsv4.org</A
>).  The=20
      advantage of NFS today is that it is mature, standard, well understoo=
d,=20
      and supported robustly across a variety of platforms.
     </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SCOPE"
>2.2. What is this HOWTO and what is it not?</A
></H2
><P
>     This HOWTO is intended as a complete, step-by-step guide to setting
     up NFS correctly and effectively.  Setting up NFS involves two steps,
     namely configuring the server and then configuring the client.  Each=20
     of these steps is dealt with in order.  The document then offers    =20
     some tips for people with particular needs and hardware setups, as  =20
     well as security and troubleshooting advice. =20
   </P
><P
>     This HOWTO is not a description of the guts and
     underlying structure of NFS.  For that you may wish to read
     <EM
>Linux NFS and Automounter Administration</EM
> by Erez Zadok (Sybex, 2001).  The classic NFS book, updated and still qui=
te useful, is <EM
>Managing NFS and NIS</EM
> by Hal Stern, published by O'Reilly &#38;
     Associates, Inc.  A much more advanced technical=20
     description of NFS is available in <EM
>NFS Illustrated</EM
> by Brent Callaghan.
   </P
><P
>     This document is also not intended as a complete reference manual,
     and does not contain an exhaustive list of the features of Linux
     NFS.  For that, you can look at the man pages for <EM
>nfs(5)</EM
>,=20
     <EM
>exports(5)</EM
>, <EM
>mount(8)</EM
>, <EM
>fstab(5)</EM
>,=20
     <EM
>nfsd(8)</EM
>, <EM
>lockd(8)</EM
>, <EM
>statd(8)</EM
>,=20
     <EM
>rquotad(8)</EM
>, and <EM
>mountd(8)</EM
>.
   </P
><P
>     It will also not cover PC-NFS, which is considered obsolete (users
     are encouraged to use Samba to share files with Windows machines) or N=
FS=20
     Version 4, which is still in development.
   </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"KNOWPREREQ"
>2.3. Knowledge Pre-Requisites</A
></H2
><P
>     You should know some basic things about TCP/IP networking before=20
     reading this HOWTO; if you are in doubt, read the=20
     <A
HREF=3D"http://www.linuxdoc.org/HOWTO/Networking-Overview-HOWTO.html"
TARGET=3D"_top"
>Networking-
     Overview-HOWTO</A
>.
   </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SWPREREQ"
>2.4. Software Pre-Requisites: Kernel Version and nfs-utils</A
></H2
><P
>     The difference between Version 2 NFS and version 3 NFS will be=20
     explained later on; for now, you might simply take the suggestion=20
     that you will need NFS Version 3 if you are installing a dedicated
     or high-volume file server.  NFS Version 2 should be fine for=20
     casual use.
   </P
><P
>     NFS Version 2 has been around for quite some time now (at least=20
     since the 1.2 kernel series) however you will need a kernel version
     of at least 2.2.18 if you wish to do any of the following:
    <P
></P
><UL
><LI
><P
>Mix Linux NFS with other operating systems' NFS</P
></LI
><LI
><P
>Use file locking reliably over NFS</P
></LI
><LI
><P
>Use NFS Version 3.</P
></LI
></UL
>
   </P
><P
>     There are also patches available for kernel versions above 2.2.14=20
     that provide the above functionality.  Some of them can be downloaded
     from the Linux NFS homepage.  If your kernel version is 2.2.14-
     2.2.17 and you have the source code on hand, you can tell if these=20
     patches have been added because NFS Version 3 server support will be=20
     a configuration option.  However, unless you have some particular
     reason to use an older kernel, you should upgrade because many bugs
     have been fixed along the way.  Kernel 2.2.19 contains some additional
     locking improvements over 2.2.18.
   </P
><P
>     Version 3 functionality will also require the nfs-utils package of=20
     at least version 0.1.6, and mount version 2.10m or newer.  However=20
     because nfs-utils and mount are fully backwards compatible, and becaus=
e=20
     newer versions have lots of security and bug fixes, there is no good=20
     reason not to install the newest nfs-utils and mount packages if you=20
     are beginning an NFS setup.
   </P
><P
>     All 2.4 and higher kernels have full NFS Version 3 functionality.
   </P
><P
>     In all cases, if you are building your own kernel, you will need
     to select NFS and NFS Version 3 support at compile time.  Most
     (but not all) standard distributions come with kernels that support
     NFS version 3.
   </P
><P
>     Handling files larger than 2 GB will require a 2.4x kernel and a=20
     2.2.x version of <SPAN
CLASS=3D"APPLICATION"
>glibc</SPAN
>.
   </P
><P
>     All kernels after 2.2.18 support NFS over TCP on the client side.
     As of this writing, server-side NFS over TCP only exists in a
     buggy form as an experimental option in the post-2.2.18 series;
     patches for 2.4 and 2.5 kernels have been introduced starting with
     2.4.17 and 2.5.6.  The patches are believed to be stable, though
     as of this writing they are relatively new and have not seen
     widespread use or integration into the mainstream 2.4 kernel.
   </P
><P
>     Because so many of the above functionalities were introduced in
     kernel version 2.2.18, this document was written to be consistent
     with kernels above this version (including 2.4.x).  If you have an
     older kernel, this document may not describe your NFS system
     correctly.
   </P
><P
>     As we write this document, NFS version 4 has only recently been
     finalized as a protocol, and no implementations are considered
     production-ready.  It will not be dealt with here.
   </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"FURTHERHELP"
>2.5. Where to get help and further information</A
></H2
><P
>    As of November 2000, the Linux NFS homepage is at=20
    <A
HREF=3D"http://nfs.sourceforge.net"
TARGET=3D"_top"
>http://nfs.sourceforge.net</A
>.  Please check there for NFS related=20
    mailing lists as well as the latest version of nfs-utils, NFS=20
    kernel patches, and other NFS related packages.
   </P
><P
>When you encounter a problem or have a question not covered in this
manual, the faq or the man pages, you should send a message to the nfs
mailing list (<TT
CLASS=3D"EMAIL"
>&#60;<A
HREF=3D"mailto:nfs@lists.sourceforge.net"
>nfs@lists.sourceforge.net</A
>&#62;</TT
>). To best help the developers
and other users help you assess your problem you should include:</P
><P
></P
><UL
><LI
><P
> the version of <SPAN
CLASS=3D"APPLICATION"
>nfs-utils</SPAN
> you are using</P
></LI
><LI
><P
> the version of the kernel and any non-stock applied kernels.</P
></LI
><LI
><P
> the distribution of linux you are using</P
></LI
><LI
><P
> the version(s) of other operating systems involved.</P
></LI
></UL
><P
>It is also useful to know the networking configuration connecting the
hosts.</P
><P
>=20
If your problem involves the inability mount or export shares please
also include:</P
><P
></P
><UL
><LI
><P
> a copy of your <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> file</P
></LI
><LI
><P
> the output of <B
CLASS=3D"COMMAND"
>rpcinfo -p</B
> <EM
>localhost</EM
> run on the server</P
></LI
><LI
><P
> the output of <B
CLASS=3D"COMMAND"
>rpcinfo -p</B
> <EM
>servername</EM
> run on the client</P
></LI
></UL
><P
>Sending all of this information with a specific question, after reading
all the documentation, is the best way to ensure a helpful response from
the list.</P
><P
>    You may also wish to look at the man pages for  <EM
>nfs(5)</EM
>,=20
     <EM
>exports(5)</EM
>, <EM
>mount(8)</EM
>, <EM
>fstab(5)</EM
>,=20
     <EM
>nfsd(8)</EM
>, <EM
>lockd(8)</EM
>, <EM
>statd(8)</EM
>,=20
     <EM
>rquotad(8)</EM
>, and <EM
>mountd(8)</EM
>.
  </P
></DIV
></DIV
><DIV
CLASS=3D"NAVFOOTER"
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
><A
HREF=3D"preamble.html"
>Prev</A
></TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
><A
HREF=3D"index.html"
>Home</A
></TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
><A
HREF=3D"server.html"
>Next</A
></TD
></TR
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
>Preamble</TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
>&nbsp;</TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
>Setting Up an NFS Server</TD
></TR
></TABLE
></DIV
></BODY
></HTML
>
--=-DzUZBAgzdIo18XiQgRt5
Content-Disposition: attachment; filename=client.html
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html; charset=ISO-8859-1

<HTML
><HEAD
><TITLE
>Setting up an NFS Client</TITLE
><META
NAME=3D"GENERATOR"
CONTENT=3D"Modular DocBook HTML Stylesheet Version 1.64
"><LINK
REL=3D"HOME"
TITLE=3D"Linux NFS-HOWTO"
HREF=3D"index.html"><LINK
REL=3D"PREVIOUS"
TITLE=3D"Setting Up an NFS Server"
HREF=3D"server.html"><LINK
REL=3D"NEXT"
TITLE=3D"Optimizing NFS Performance"
HREF=3D"performance.html"></HEAD
><BODY
CLASS=3D"SECT1"
BGCOLOR=3D"#FFFFFF"
TEXT=3D"#000000"
LINK=3D"#0000FF"
VLINK=3D"#840084"
ALINK=3D"#0000FF"
><DIV
CLASS=3D"NAVHEADER"
><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TH
COLSPAN=3D"3"
ALIGN=3D"center"
>Linux NFS-HOWTO</TH
></TR
><TR
><TD
WIDTH=3D"10%"
ALIGN=3D"left"
VALIGN=3D"bottom"
><A
HREF=3D"server.html"
>Prev</A
></TD
><TD
WIDTH=3D"80%"
ALIGN=3D"center"
VALIGN=3D"bottom"
></TD
><TD
WIDTH=3D"10%"
ALIGN=3D"right"
VALIGN=3D"bottom"
><A
HREF=3D"performance.html"
>Next</A
></TD
></TR
></TABLE
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"></DIV
><DIV
CLASS=3D"SECT1"
><H1
CLASS=3D"SECT1"
><A
NAME=3D"CLIENT"
>4. Setting up an NFS Client</A
></H1
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"REMOTEMOUNT"
>4.1. Mounting remote directories</A
></H2
><P
>    Before beginning, you should double-check to make sure your mount=20
    program is new enough (version 2.10m if you want to use Version 3=20
    NFS), and that the client machine supports NFS mounting, though most
    standard distributions do.  If you are using a 2.2 or later kernel=20
    with the <TT
CLASS=3D"FILENAME"
>/proc</TT
> filesystem you can check the latter by reading the=20
    file <TT
CLASS=3D"FILENAME"
>/proc/filesystems</TT
> and making sure there is a line containing=20
    nfs.  If not, typing <TT
CLASS=3D"USERINPUT"
><B
>insmod nfs</B
></TT
> may make it
    magically appear if NFS has been compiled as a module; otherwise,
    you will need to build (or download) a kernel that has=20
    NFS support built in.  In general, kernels that do not have NFS
    compiled in will give a very specific error when the=20
    <B
CLASS=3D"COMMAND"
>mount</B
> command below is run.
  </P
><P
>    To begin using machine as an NFS client, you will need the portmapper=20
    running on that machine, and to use NFS file locking, you will
    also need <B
CLASS=3D"COMMAND"
>rpc.statd</B
> and <B
CLASS=3D"COMMAND"
>rpc.lockd</B
>
    running on both the client and the server.  Most recent distributions=20
    start those services by default at boot time; if yours doesn't, see=20
    <A
HREF=3D"server.html#CONFIG"
>Section 3.2</A
> for information on how to start them up.
  </P
><P
>    With <B
CLASS=3D"COMMAND"
>portmap</B
>, <B
CLASS=3D"COMMAND"
>lockd</B
>,=20
    and <B
CLASS=3D"COMMAND"
>statd</B
> running, you should now be able to=20
    mount the remote directory from your server just the way you mount=20
    a local hard drive, with the mount command.  Continuing our example=20
    from the previous section, suppose our server above is called=20
    <EM
>master.foo.com</EM
>,and we want to mount the <TT
CLASS=3D"FILENAME"
>/home</TT
> directory on=20
    <EM
>slave1.foo.com</EM
>.  Then, all we have to do, from the root prompt on=20
    <EM
>slave1.foo.com</EM
>, is type:
  <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>   # mount master.foo.com:/home /mnt/home
  </PRE
></FONT
></TD
></TR
></TABLE
>
  and the directory <TT
CLASS=3D"FILENAME"
>/home</TT
> on master will appear as the directory=20
  <TT
CLASS=3D"FILENAME"
>/mnt/home</TT
> on <EM
>slave1</EM
>.  (Note that
  this assumes we have created the directory <TT
CLASS=3D"FILENAME"
>/mnt/home</TT
>=20
  as an empty mount point beforehand.)
 </P
><P
>   If this does not work, see the Troubleshooting section (<A
HREF=3D"troubleshooting.html"
>Section 7</A
>).
 </P
><P
>   You can get rid of the file system by typing=20
  <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>   # umount /mnt/home=20
  </PRE
></FONT
></TD
></TR
></TABLE
>
 just like you would for a local file system.
 </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"BOOT-TIME-NFS"
>4.2. Getting NFS File Systems to Be Mounted at Boot Time</A
></H2
><P
>   NFS file systems can be added to your <TT
CLASS=3D"FILENAME"
>/etc/fstab</TT
> file the same way
   local file systems can, so that they mount when your system starts
   up.  The only difference is that the file system type will be
   set to <TT
CLASS=3D"USERINPUT"
><B
>nfs</B
></TT
> and the dump and fsck order (the last two entries) will
   have to be set to zero.  So for our example above, the entry in
   <TT
CLASS=3D"FILENAME"
>/etc/fstab</TT
> would look like:
  <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>   # device       mountpoint     fs-type     options      dump fsckorder
   ...
   master.foo.com:/home  /mnt    nfs          rw            0    0
   ...
  </PRE
></FONT
></TD
></TR
></TABLE
>
 </P
><P
>   See the man pages for <TT
CLASS=3D"FILENAME"
>fstab</TT
> if you are unfamiliar=20
   with the syntax of this file.  If you are using an automounter such as=20
   amd or autofs, the options in the corresponding fields of your mount=20
   listings should look very similar if not identical.
 </P
><P
>   At this point you should have NFS working, though a few tweaks
   may still be necessary to get it to work well.  You should also
   read <A
HREF=3D"security.html"
>Section 6</A
> to be sure your setup is reasonably secure.
 </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"MOUNTOPTIONS"
>4.3. Mount options</A
></H2
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"SOFT-VS-HARD"
>4.3.1. Soft vs. Hard Mounting</A
></H3
><P
>     There are some options you should consider adding at once.  They
     govern the way the NFS client handles a server crash or network
     outage.  One of the cool things about NFS is that it can handle this
     gracefully.  If you set up the clients right.  There are two distinct
     failure modes:
   </P
><P
>  <DIV
CLASS=3D"GLOSSLIST"
><DL
><DT
><B
>soft</B
></DT
><DD
><P
>   If a file request fails, the NFS client will report an=20
   error to the process on the client machine requesting the file=20
   access.  Some programs can handle this with composure, most=20
   won't.  We do not recommend using this setting; it is a recipe=20
   for corrupted files and lost data.  You should especially not=20
   use this for mail disks --- if you value your mail, that is.
   </P
></DD
><DT
><B
>hard</B
></DT
><DD
><P
>     The program accessing a file on a NFS mounted file system
     will hang when the server crashes.  The process cannot be=20
     interrupted or killed (except by a "sure kill") unless you also=20
     specify <TT
CLASS=3D"USERINPUT"
><B
>intr</B
></TT
>.  When the=20
     NFS server is back online the program will
     continue undisturbed from where it was.  We recommend using=20
     <TT
CLASS=3D"USERINPUT"
><B
>hard,intr</B
></TT
> on all NFS mounted file systems.
    </P
></DD
></DL
></DIV
>
  </P
><P
>  Picking up the from previous example, the fstab entry would now=20
  look like:
  <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>   # device             mountpoint  fs-type    options    dump fsckord
   ...
   master.foo.com:/home  /mnt/home   nfs      rw,hard,intr  0     0
   ...
  </PRE
></FONT
></TD
></TR
></TABLE
>
 </P
></DIV
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"BLOCKSIZE"
>4.3.2. Setting Block Size to Optimize Transfer Speeds</A
></H3
><P
>   The <TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
> and <TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
> mount=20
   options specify the size of the chunks of data that the client and=20
   server pass back and forth to each other.
 </P
><P
>  The defaults may be too big or to small; there is no size that works
  well on all or most setups.  On the one hand, some combinations of=20
  Linux kernels and network cards (largely on older machines) cannot
  handle blocks that large. On the other hand, if they can handle=20
  larger blocks, a bigger size might be faster.
 </P
><P
>   Getting the block size right is an important factor in performance and
   is a must if you are planning to use the NFS server in a production
   environment.  See <A
HREF=3D"performance.html"
>Section 5</A
> for details.
 </P
></DIV
></DIV
></DIV
><DIV
CLASS=3D"NAVFOOTER"
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
><A
HREF=3D"server.html"
>Prev</A
></TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
><A
HREF=3D"index.html"
>Home</A
></TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
><A
HREF=3D"performance.html"
>Next</A
></TD
></TR
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
>Setting Up an NFS Server</TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
>&nbsp;</TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
>Optimizing NFS Performance</TD
></TR
></TABLE
></DIV
></BODY
></HTML
>
--=-DzUZBAgzdIo18XiQgRt5
Content-Disposition: attachment; filename=server.html
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html; charset=ISO-8859-1

<HTML
><HEAD
><TITLE
>Setting Up an NFS Server</TITLE
><META
NAME=3D"GENERATOR"
CONTENT=3D"Modular DocBook HTML Stylesheet Version 1.64
"><LINK
REL=3D"HOME"
TITLE=3D"Linux NFS-HOWTO"
HREF=3D"index.html"><LINK
REL=3D"PREVIOUS"
TITLE=3D"Introduction"
HREF=3D"intro.html"><LINK
REL=3D"NEXT"
TITLE=3D"Setting up an NFS Client"
HREF=3D"client.html"></HEAD
><BODY
CLASS=3D"SECT1"
BGCOLOR=3D"#FFFFFF"
TEXT=3D"#000000"
LINK=3D"#0000FF"
VLINK=3D"#840084"
ALINK=3D"#0000FF"
><DIV
CLASS=3D"NAVHEADER"
><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TH
COLSPAN=3D"3"
ALIGN=3D"center"
>Linux NFS-HOWTO</TH
></TR
><TR
><TD
WIDTH=3D"10%"
ALIGN=3D"left"
VALIGN=3D"bottom"
><A
HREF=3D"intro.html"
>Prev</A
></TD
><TD
WIDTH=3D"80%"
ALIGN=3D"center"
VALIGN=3D"bottom"
></TD
><TD
WIDTH=3D"10%"
ALIGN=3D"right"
VALIGN=3D"bottom"
><A
HREF=3D"client.html"
>Next</A
></TD
></TR
></TABLE
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"></DIV
><DIV
CLASS=3D"SECT1"
><H1
CLASS=3D"SECT1"
><A
NAME=3D"SERVER"
>3. Setting Up an NFS Server</A
></H1
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SERVERINTRO"
>3.1. Introduction to the server setup</A
></H2
><P
>    It is assumed that you will be setting up both a server and a
    client.  If you are just setting up a client to work off of
    somebody else's server (say in your department), you can skip
    to <A
HREF=3D"client.html"
>Section 4</A
>.  However, every client that is set up requires
    modifications on the server to authorize that client (unless=20
    the server setup is done in a very insecure way), so even if you
    are not setting up a server you may wish to read this section to
    get an idea what kinds of authorization problems to look out for.
 </P
><P
>    Setting up the server will be done in two steps: Setting up the=20
    configuration files for NFS, and then starting the NFS services.
 </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"CONFIG"
>3.2. Setting up the Configuration Files</A
></H2
><P
>   There are three main configuration files you will need to edit to=20
   set up an NFS server: <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
>,
   <TT
CLASS=3D"FILENAME"
>/etc/hosts.allow</TT
>, and  <TT
CLASS=3D"FILENAME"
>/etc/hosts.deny</TT
>.=20
   Strictly speaking, you only need to edit <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> to get=20
   NFS to work, but you would be left with an extremely insecure setup. You=
 may also need=20
   to edit your startup scripts; see <A
HREF=3D"server.html#DAEMONS"
>Section 3.3.3</A
> for more on that.
 </P
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"EXPORTS"
>3.2.1. /etc/exports</A
></H3
><P
>   This file contains a list of entries; each entry indicates a volume
   that is shared and how it is shared.  Check the man pages (<B
CLASS=3D"COMMAND"
>man=20
   exports</B
>) for a complete description of all the setup options for=20
   the file, although the description here will probably satistfy=20
   most people's needs.
 </P
><P
>   An entry in <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> will typically look like this:
 <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
> directory machine1(option11,option12) machine2(option21,option22)</PRE
></FONT
></TD
></TR
></TABLE
></P
><P
>  where=20
  <DIV
CLASS=3D"GLOSSLIST"
><DL
><DT
><B
>directory</B
></DT
><DD
><P
>    the directory that you want to share.  It may be an=20
    entire volume though it need not be.  If you share a directory,=20
    then all directories under it within the same file system will=20
    be shared as well.
   </P
></DD
><DT
><B
>machine1 and machine2</B
></DT
><DD
><P
>    client machines that will have access to the directory. The machines
    may be listed by their DNS address or their IP address=20
    (e.g., <EM
>machine.company.com</EM
> or <EM
>192.168.0.8</EM
>).
    Using IP addresses is more reliable and more secure.  If you need to
    use DNS addresses, and they do not seem to be resolving to the right
    machine, see <A
HREF=3D"troubleshooting.html#SYMPTOM3"
>Section 7.3</A
>.
   </P
></DD
><DT
><B
>optionxx</B
></DT
><DD
><P
>    the option listing for each machine will describe what kind of=20
    access that machine will have.  Important options are:
    <P
></P
><UL
><LI
><P
>       <TT
CLASS=3D"USERINPUT"
><B
>ro</B
></TT
>:  The directory is shared read only; the client machine=20
      will not be able to write to it.  This is the default.
    </P
></LI
><LI
><P
>       <TT
CLASS=3D"USERINPUT"
><B
>rw</B
></TT
>:  The client machine will have read and write access to the=20
      directory.
     </P
></LI
><LI
><P
>       <TT
CLASS=3D"USERINPUT"
><B
>no_root_squash</B
></TT
>: By default,
       any file request made by user <TT
CLASS=3D"COMPUTEROUTPUT"
>root</TT
>=20
       on the client machine is treated as if it is made by user=20
       <TT
CLASS=3D"COMPUTEROUTPUT"
>nobody</TT
> on the=20
       server.  (Excatly which UID the request is=20
       mapped to depends on the UID of user "nobody" on the server,
       not the client.)  If <TT
CLASS=3D"USERINPUT"
><B
>no_root_squash</B
></TT
>=20
       is selected, then=20
       root on the client machine will have the same level of access=20
       to the files on the system as root on the server.  This=20
       can have serious security implications, although it may be=20
       necessary if you want to perform any administrative work on=20
       the client machine that involves the exported directories.
       You should not specify this option without a good reason.
     </P
></LI
><LI
><P
>       <TT
CLASS=3D"USERINPUT"
><B
>no_subtree_check</B
></TT
>: If only part of a volume is exported, a
       routine called subtree checking verifies that a file that is=20
       requested from the client is in the appropriate part of the=20
       volume.  If the entire volume is exported, disabling this check
       will speed up transfers.
     </P
></LI
><LI
><P
>       <TT
CLASS=3D"USERINPUT"
><B
>sync</B
></TT
>:
       By default, all but the most recent version (version 1.11)
       of the <B
CLASS=3D"COMMAND"
>exportfs</B
> command will use=20
       <TT
CLASS=3D"USERINPUT"
><B
>async</B
></TT
> behavior, telling a client=20
       machine that a file write is complete - that is, has been written=20
       to stable storage - when NFS has finished handing the write over to=20
       the filesysytem.  This behavior may cause data corruption if the=20
       server reboots, and the <TT
CLASS=3D"USERINPUT"
><B
>sync</B
></TT
> option prevents=20
       this.  See <A
HREF=3D"performance.html#SYNC-ASYNC"
>Section 5.9</A
> for a complete discussion of=20
       <TT
CLASS=3D"USERINPUT"
><B
>sync</B
></TT
> and <TT
CLASS=3D"USERINPUT"
><B
>async</B
></TT
> behavior.
    </P
></LI
></UL
>
  </P
></DD
></DL
></DIV
></P
><P
>  Suppose we have two client machines, <EM
>slave1</EM
> and <EM
>slave2</EM
>, that have IP
  addresses <EM
>192.168.0.1</EM
> and <EM
>192.168.0.2</EM
>, respectively.  We wish to share
  our software binaries and home directories with these machines.
  A typical setup for <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> might look like this:
 <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>  /usr/local   192.168.0.1(ro) 192.168.0.2(ro)
  /home        192.168.0.1(rw) 192.168.0.2(rw)
 </PRE
></FONT
></TD
></TR
></TABLE
></P
><P
>  Here we are sharing <TT
CLASS=3D"FILENAME"
>/usr/local</TT
> read-only to slave1 and slave2,=20
  because it probably contains our software and there may not be=20
  benefits to allowing slave1 and slave2 to write to it that outweigh=20
  security concerns.  On the other hand, home directories need to be=20
  exported read-write if users are to save work on them.</P
><P
>  If you have a large installation, you may find that you have a bunch=20
  of computers all on the same local network that require access to=20
  your server.  There are a few ways of simplifying references
  to large numbers of machines.  First, you can give access to a range=20
  of machines at once by specifying a network and a netmask.  For=20
  example, if you wanted to allow access to all the machines with IP=20
  addresses between <EM
>192.168.0.0</EM
> and
<EM
>192.168.0.255</EM
> then you could have the entries:
 <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>  /usr/local 192.168.0.0/255.255.255.0(ro)
  /home      192.168.0.0/255.255.255.0(rw)
 </PRE
></FONT
></TD
></TR
></TABLE
></P
><P
>  See the <A
HREF=3D"http://www.linuxdoc.org/HOWTO/Networking-Overview-HOWTO.html"
TARGET=3D"_top"
>Networking-Overview HOWTO</A
>
  for further information about how netmasks work, and you may also wish to=
=20
  look at the man pages for <TT
CLASS=3D"FILENAME"
>init</TT
> and <TT
CLASS=3D"FILENAME"
>hosts.allow</TT
>.</P
><P
>  Second, you can use NIS netgroups in your entry. To specify a
  netgroup in your exports file, simply prepend the name of the
  netgroup with an "@".  See the <A
HREF=3D"http://www.linuxdoc.org/HOWTO/NIS-HOWTO.html"
TARGET=3D"_top"
>NIS HOWTO</A
>
  for details on how netgroups work. </P
><P
>  Third, you can use wildcards such as <EM
>*.foo.com</EM
> or
 <EM
>192.168.</EM
> instead of hostnames.  There were problems
  with wildcard implementation in the 2.2 kernel series that were fixed
  in kernel 2.2.19.</P
><P
>  However, you should keep in mind that any of these simplifications
  could cause a security risk if there are machines in your netgroup
  or local network that you do not trust completely.</P
><P
>  A few cautions are in order about what cannot (or should not) be
  exported.  First, if a directory is exported, its parent and child
  directories cannot be exported if they are in the same filesystem.
  However, exporting both should not be necessary because listing the
  parent directory in the <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> file will cause all underlying
  directories within that file system to be exported.  </P
><P
>  Second, it is a poor idea to export a FAT or VFAT (i.e., MS-DOS or=20
  Windows 95/98) filesystem with NFS.  FAT is not designed for use on a=20
  multi-user machine, and as a result, operations that depend on=20
  permissions will not work well.  Moreover, some of the underlying=20
  filesystem design is reported to work poorly with NFS's expectations.  </=
P
><P
>  Third, device or other special files may not export correctly to non-Lin=
ux=20
  clients.  See <A
HREF=3D"interop.html"
>Section 8</A
> for details on particular operating systems.</P
></DIV
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"HOSTS"
>3.2.2. /etc/hosts.allow and /etc/hosts.deny</A
></H3
><P
>   These two files specify which computers on the network can use=20
   services on your machine.  Each line of the file=20
   contains a single entry listing=20
   a service and a set of machines.  When the server gets a request=20
   from a machine, it does the following:
  <P
></P
><UL
><LI
><P
>     It first checks <TT
CLASS=3D"FILENAME"
>hosts.allow</TT
> to see if the machine=20
     matches a description listed in there. If it does, then the machine
     is allowed access. =20
   </P
></LI
><LI
><P
>     If the machine does not match an entry in <TT
CLASS=3D"FILENAME"
>hosts.allow</TT
>, the
     server then checks <TT
CLASS=3D"FILENAME"
>hosts.deny</TT
> to see if the client matches a=20
     listing in there.  If it does then the machine is denied  access. =20
   </P
></LI
><LI
><P
>     If the client matches no listings in either file, then it
     is allowed access.
   </P
></LI
></UL
>
 </P
><P
>   In addition to controlling access to services handled by inetd (such=20
   as telnet and FTP), this file can also control access to NFS
   by restricting connections to the daemons that provide NFS services.
   Restrictions are done on a per-service basis.
 </P
><P
>   The first daemon to restrict access to is the portmapper.  This daemon
   essentially just tells requesting clients how to find all the NFS
   services on the system.  Restricting access to the portmapper is the
   best defense against someone breaking into your system through NFS
   because completely unauthorized clients won't know where to find the
   NFS daemons.  However, there are two things to watch out for.  First,
   restricting portmapper isn't enough if the intruder already knows
   for some reason how to find those daemons.  And second, if you are
   running NIS, restricting portmapper will also restrict requests to NIS.
   That should usually be harmless since you usually want
   to restrict NFS and NIS in a similar way, but just be cautioned.
   (Running NIS is generally a good idea if you are running NFS, because
   the client machines need a way of knowing who owns what files on the
   exported volumes.  Of course there are other ways of doing this such
   as syncing password files.  See the <A
HREF=3D"http://www.linuxdoc.org/HOWTO/NIS-HOWTO.html"
TARGET=3D"_top"
>NIS HOWTO</A
> for information on
   setting up NIS.)
 </P
><P
>   In general it is a good idea with NFS (as with most internet services)
   to explicitly deny access to IP addresses that you don't need
   to allow access to.
 </P
><P
>   The first step in doing this is to add the followng entry to=20
   <TT
CLASS=3D"FILENAME"
>/etc/hosts.deny</TT
>:
 </P
><P
>  <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>   portmap:ALL
  </PRE
></FONT
></TD
></TR
></TABLE
>
 </P
><P
>   Starting with <SPAN
CLASS=3D"APPLICATION"
>nfs-utils</SPAN
> 0.2.0, you can be a bit more careful by
   controlling access to individual daemons.  It's a good precaution
   since an intruder will often be able to weasel around the portmapper.
   If you have a newer version of <SPAN
CLASS=3D"APPLICATION"
>nfs-utils</SPAN
>, add entries for each of the
   NFS daemons (see the next section to find out what these daemons are;
   for now just put entries for them in hosts.deny):
 </P
><P
>  <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>    lockd:ALL
    mountd:ALL
    rquotad:ALL
    statd:ALL
  </PRE
></FONT
></TD
></TR
></TABLE
>
 </P
><P
>=20
   Even if you have an older version of <SPAN
CLASS=3D"APPLICATION"
>nfs-utils</SPAN
>, adding these entries
   is at worst harmless (since they will just be ignored) and at best=20
   will save you some trouble when you upgrade.  Some sys admins choose
   to put the entry <TT
CLASS=3D"USERINPUT"
><B
>ALL:ALL</B
></TT
> in the file <TT
CLASS=3D"FILENAME"
>/etc/hosts.deny</TT
>,=20
   which causes  any service that looks at these files to deny access to al=
l=20
   hosts unless it is explicitly allowed.  While this is more secure=20
   behavior, it may also get you in trouble when you are installing new=20
   services,  you forget you put it there, and you can't figure out for=20
   the life of you why they won't work.
 </P
><P
>   Next, we need to add an entry to <TT
CLASS=3D"FILENAME"
>hosts.allow</TT
> to give any hosts=20
   access that we want to have access.  (If we just leave the above=20
   lines in <TT
CLASS=3D"FILENAME"
>hosts.deny</TT
> then nobody will have access to NFS.)  Entries=20
   in <TT
CLASS=3D"FILENAME"
>hosts.allow</TT
> follow the format
  <DIV
CLASS=3D"INFORMALEXAMPLE"
><A
NAME=3D"AEN270"
></A
><P
></P
><TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>    service: host [or network/netmask] , host [or network/netmask]
   </PRE
></FONT
></TD
></TR
></TABLE
><P
></P
></DIV
>
 </P
><P
>   Here, host is IP address of a potential client; it may be possible=20
   in some versions to use the DNS name of the host, but it is strongly=20
   discouraged.
 </P
><P
>   Suppose we have the setup above and we just want to allow access
   to <EM
>slave1.foo.com</EM
> and <EM
>slave2.foo.com</EM
>,=20
   and suppose that the IP addresses of these machines are <EM
>192.168.0.1</EM
>
   and <EM
>192.168.0.2</EM
>, respectively.  We could add the following entry to=20
   <TT
CLASS=3D"FILENAME"
>/etc/hosts.allow</TT
>:
  <DIV
CLASS=3D"INFORMALEXAMPLE"
><A
NAME=3D"AEN279"
></A
><P
></P
><TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>   portmap: 192.168.0.1 , 192.168.0.2
   </PRE
></FONT
></TD
></TR
></TABLE
><P
></P
></DIV
>
 </P
><P
>   For recent nfs-utils versions, we would also add the following
   (again, these entries are harmless even if they are not supported):
  <DIV
CLASS=3D"INFORMALEXAMPLE"
><A
NAME=3D"AEN282"
></A
><P
></P
><TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>    lockd: 192.168.0.1 , 192.168.0.2
    rquotad: 192.168.0.1 , 192.168.0.2
    mountd: 192.168.0.1 , 192.168.0.2
    statd: 192.168.0.1 , 192.168.0.2
   </PRE
></FONT
></TD
></TR
></TABLE
><P
></P
></DIV
>
 </P
><P
>   If you intend to run NFS on a large number of machines in a local
   network, <TT
CLASS=3D"FILENAME"
>/etc/hosts.allow</TT
> also allows for network/netmask style=20
   entries in the same manner as <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> above.
 </P
></DIV
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SERVICESTART"
>3.3. Getting the services started</A
></H2
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"PREREQ"
>3.3.1. Pre-requisites</A
></H3
><P
>    The NFS server should now be configured and we can start it running.
    First, you will need to have the appropriate packages installed. =20
    This consists mainly of a new enough kernel and a new enough version
    of the <SPAN
CLASS=3D"APPLICATION"
>nfs-utils</SPAN
> package. =20
    See <A
HREF=3D"intro.html#SWPREREQ"
>Section 2.4</A
> if you are in doubt.
  </P
><P
>    Next, before you can start NFS, you will need to have TCP/IP=20
    networking functioning correctly on your machine.  If you can use=20
    telnet, FTP, and so on, then chances are your TCP networking is fine.
  </P
><P
>    That said, with most recent Linux distributions you may be able to=20
    get NFS up and running simply by rebooting your machine, and the=20
    startup scripts should detect that you have set up your <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
>
    file and will start up NFS correctly.  If you try this, see <A
HREF=3D"server.html#VERIFY"
>Section 3.4</A
>
    Verifying that NFS is running.  If this does not work, or if=20
    you are not in a position to reboot your machine, then the following
    section will tell you which daemons need to be started in order to=20
    run NFS services.  If for some reason <B
CLASS=3D"COMMAND"
>nfsd</B
>=20
    was already running when
    you edited your configuration files above, you will have to flush=20
    your configuration; see <A
HREF=3D"server.html#LATER"
>Section 3.5</A
> for details.
  </P
></DIV
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"PORTMAPPER"
>3.3.2. Starting the Portmapper</A
></H3
><P
>     NFS depends on the portmapper daemon, either called <B
CLASS=3D"COMMAND"
>portmap</B
> or=20
     <B
CLASS=3D"COMMAND"
>rpc.portmap</B
>.  It will need to be started first.  It should be=20
     located in <TT
CLASS=3D"FILENAME"
>/sbin</TT
> but is sometimes in <TT
CLASS=3D"FILENAME"
>/usr/sbin</TT
>. =20
     Most recent Linux distributions start this daemon in the boot scripts,=
 but it is=20
     worth making sure that it is running before you begin working with=20
     NFS (just type <B
CLASS=3D"COMMAND"
>ps aux | grep portmap</B
>).
   </P
></DIV
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"DAEMONS"
>3.3.3. The Daemons</A
></H3
><P
>     NFS serving is taken care of by five daemons: <B
CLASS=3D"COMMAND"
>rpc.nfsd</B
>,=20
     which does most of the work; <B
CLASS=3D"COMMAND"
>rpc.lockd</B
> and=20
     <B
CLASS=3D"COMMAND"
>rpc.statd</B
>, which handle file locking;
     <B
CLASS=3D"COMMAND"
>rpc.mountd</B
>, which handles the initial mount requests,=20
     and <B
CLASS=3D"COMMAND"
>rpc.rquotad</B
>, which handles user file quotas on=20
     exported volumes. Starting with 2.2.18, <B
CLASS=3D"COMMAND"
>lockd</B
>=20
     is called by <B
CLASS=3D"COMMAND"
>nfsd</B
> upon demand, so you do
     not need to worry about starting it yourself. <B
CLASS=3D"COMMAND"
>statd</B
>=20
     will need to be started separately. Most recent Linux distributions wi=
ll
     have startup scripts for these daemons.
   </P
><P
>     The daemons are all part of the nfs-utils package, and may be either
     in the <TT
CLASS=3D"FILENAME"
>/sbin</TT
> directory or the <TT
CLASS=3D"FILENAME"
>/usr/sbin</TT
> directory.
   </P
><P
>    If your distribution does not include them in the startup scripts,=20
    then then you should add them, configured to start in the following=20
    order:
  <P
></P
><TABLE
BORDER=3D"0"
><TBODY
><TR
><TD
><B
CLASS=3D"COMMAND"
>rpc.portmap</B
></TD
></TR
><TR
><TD
><B
CLASS=3D"COMMAND"
>rpc.mountd</B
>, <B
CLASS=3D"COMMAND"
>rpc.nfsd</B
></TD
></TR
><TR
><TD
><B
CLASS=3D"COMMAND"
>rpc.statd</B
>, <B
CLASS=3D"COMMAND"
>rpc.lockd</B
> (if necessary), and <B
CLASS=3D"COMMAND"
>rpc.rquotad</B
></TD
></TR
></TBODY
></TABLE
><P
></P
>
 </P
><P
>   The nfs-utils package has sample startup scripts for RedHat and
   Debian.  If you are using a different distribution, in general you
   can just copy the RedHat script, but you will probably have to take
   out the line that says:
   <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>    . ../init.d/functions
   </PRE
></FONT
></TD
></TR
></TABLE
>
   to avoid getting error messages.
 </P
></DIV
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"VERIFY"
>3.4. Verifying that NFS is running</A
></H2
><P
>    To do this, query the portmapper with the command <B
CLASS=3D"COMMAND"
>rpcinfo -p</B
> to=20
    find out what services it is providing.  You should get something=20
    like this:
   <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>    program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100011    1   udp    749  rquotad
    100011    2   udp    749  rquotad
    100005    1   udp    759  mountd
    100005    1   tcp    761  mountd
    100005    2   udp    764  mountd
    100005    2   tcp    766  mountd
    100005    3   udp    769  mountd
    100005    3   tcp    771  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    300019    1   tcp    830  amd
    300019    1   udp    831  amd
    100024    1   udp    944  status
    100024    1   tcp    946  status
    100021    1   udp   1042  nlockmgr
    100021    3   udp   1042  nlockmgr
    100021    4   udp   1042  nlockmgr
    100021    1   tcp   1629  nlockmgr
    100021    3   tcp   1629  nlockmgr
    100021    4   tcp   1629  nlockmgr
  </PRE
></FONT
></TD
></TR
></TABLE
>
 </P
><P
>   This says that we have NFS versions 2 and 3, rpc.statd version 1,=20
   network lock manager (the service name for rpc.lockd) versions 1, 3,=20
   and 4.  There are also different service listings depending on=20
   whether NFS is travelling over TCP or UDP.  Linux systems use UDP
   by default unless TCP is explicitly requested; however other OSes=20
   such as Solaris default to TCP.
 </P
><P
>   If you do not at least see a line that says=20
   <TT
CLASS=3D"COMPUTEROUTPUT"
>portmapper</TT
>, a line that says=20
   <TT
CLASS=3D"COMPUTEROUTPUT"
>nfs</TT
>, and a line that says=20
   <TT
CLASS=3D"COMPUTEROUTPUT"
>mountd</TT
> then you will need=20
   to backtrack and try again to start up the daemons=20
   (see <A
HREF=3D"troubleshooting.html"
>Section 7</A
>,=20
   Troubleshooting, if this still doesn't work).
 </P
><P
>   If you do see these services listed, then you should be ready to=20
   set up NFS clients to access files from your server.
 </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"LATER"
>3.5. Making changes to /etc/exports later on</A
></H2
><P
>   If you come back and change your <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> file, the changes you=20
   make may not take effect immediately.  You should run the command=20
   <B
CLASS=3D"COMMAND"
>exportfs -ra</B
> to force nfsd to re-read the <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
>
=A0  file.  If you can't find the <B
CLASS=3D"COMMAND"
>exportfs</B
> command, then you can kill nfsd with the=20
  <TT
CLASS=3D"USERINPUT"
><B
> -HUP</B
></TT
> flag (see the man pages for kill for details).
 </P
><P
>   If that still doesn't work, don't forget to check <TT
CLASS=3D"FILENAME"
>hosts.allow</TT
> to=20
   make sure you haven't forgotten to list any new client machines=20
   there.  Also check the host listings on any firewalls you may have=20
   set up (see <A
HREF=3D"troubleshooting.html"
>Section 7</A
> and=20
   <A
HREF=3D"security.html"
>Section 6</A
> for more details on firewalls and NFS).
 </P
></DIV
></DIV
><DIV
CLASS=3D"NAVFOOTER"
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
><A
HREF=3D"intro.html"
>Prev</A
></TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
><A
HREF=3D"index.html"
>Home</A
></TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
><A
HREF=3D"client.html"
>Next</A
></TD
></TR
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
>Introduction</TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
>&nbsp;</TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
>Setting up an NFS Client</TD
></TR
></TABLE
></DIV
></BODY
></HTML
>
--=-DzUZBAgzdIo18XiQgRt5
Content-Disposition: attachment; filename=preamble.html
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html; charset=ISO-8859-1

<HTML
><HEAD
><TITLE
>Preamble</TITLE
><META
NAME=3D"GENERATOR"
CONTENT=3D"Modular DocBook HTML Stylesheet Version 1.64
"><LINK
REL=3D"HOME"
TITLE=3D"Linux NFS-HOWTO"
HREF=3D"index.html"><LINK
REL=3D"PREVIOUS"
TITLE=3D"Linux NFS-HOWTO"
HREF=3D"index.html"><LINK
REL=3D"NEXT"
TITLE=3D"Introduction"
HREF=3D"intro.html"></HEAD
><BODY
CLASS=3D"SECT1"
BGCOLOR=3D"#FFFFFF"
TEXT=3D"#000000"
LINK=3D"#0000FF"
VLINK=3D"#840084"
ALINK=3D"#0000FF"
><DIV
CLASS=3D"NAVHEADER"
><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TH
COLSPAN=3D"3"
ALIGN=3D"center"
>Linux NFS-HOWTO</TH
></TR
><TR
><TD
WIDTH=3D"10%"
ALIGN=3D"left"
VALIGN=3D"bottom"
><A
HREF=3D"index.html"
>Prev</A
></TD
><TD
WIDTH=3D"80%"
ALIGN=3D"center"
VALIGN=3D"bottom"
></TD
><TD
WIDTH=3D"10%"
ALIGN=3D"right"
VALIGN=3D"bottom"
><A
HREF=3D"intro.html"
>Next</A
></TD
></TR
></TABLE
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"></DIV
><DIV
CLASS=3D"SECT1"
><H1
CLASS=3D"SECT1"
><A
NAME=3D"PREAMBLE"
>1. Preamble</A
></H1
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"LEGAL"
>1.1. Legal stuff</A
></H2
><P
>Copyright (c) &#60;2002&#62; by Tavis Barr, Nicolai Langfeldt,=20
Seth Vidal, and Tom McNeal.  =20
This material may be distributed only subject to the terms and conditions s=
et=20
forth in the Open Publication License, v1.0 or later (the latest version=20
is presently available at <A
HREF=3D"http://www.opencontent.org/openpub/"
TARGET=3D"_top"
>http://www.opencontent.org/openpub/</A
>).</P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"DISCLAIMER"
>1.2. Disclaimer</A
></H2
><P
>This document is provided without any guarantees, including=20
merchantability or fitness for a particular use.  The maintainers
cannot be responsible if following instructions in this document
leads to damaged equipment or data, angry neighbors, strange habits,=20
divorce, or any other calamity.</P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"FEEDBACK"
>1.3. Feedback</A
></H2
><P
>This will never be a finished document; we welcome feedback about=20
  how it can be improved.  As of February 2002, the Linux NFS home=20
  page is  being hosted at <A
HREF=3D"http://nfs.sourceforge.net"
TARGET=3D"_top"
>http://nfs.sourceforge.net</A
>.  Check there=20
  for mailing lists, bug fixes, and updates, and also to verify
  who currently maintains this document.
 </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"TRANSLATION"
>1.4. Translation</A
></H2
><P
>If you are able to translate this document into another language,=20
we would be grateful and we will also do our best to assist you.
Please notify the maintainers.</P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"DEDICATION"
>1.5. Dedication</A
></H2
><P
>NFS on Linux was made possible by a collaborative effort of many=20
people, but a few stand out for special recognition.  The original
version was developed by Olaf Kirch and Alan Cox.  The version 3=20
server code was solidified by Neil Brown, based on work from
Saadia Khan, James Yarbrough, Allen Morris, H.J. Lu, and others
(including himself).  The client code was written by Olaf Kirch and=20
updated by Trond Myklebust.  The version 4 lock manager was developed=20
by Saadia Khan.  Dave Higgen and H.J. Lu both have undertaken the
thankless job of extensive maintenance and bug fixes to get the=20
code to actually work the way it was supposed to.  H.J. has also
done extensive development of the nfs-utils package.  Of course this=20
dedication is leaving many people out.</P
><P
>The original version of this document was developed by Nicolai=20
Langfeldt.  It was heavily rewritten in 2000 by Tavis Barr
and Seth Vidal to reflect substantial changes in the workings
of NFS for Linux developed between the 2.0 and 2.4 kernels.
It was edited again in February 2002, when Tom McNeal made substantial
additions to the performance section.
Thomas Emmel, Neil Brown, Trond Myklebust, Erez Zadok, and Ion Badulescu
also provided valuable comments and contributions.</P
></DIV
></DIV
><DIV
CLASS=3D"NAVFOOTER"
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
><A
HREF=3D"index.html"
>Prev</A
></TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
><A
HREF=3D"index.html"
>Home</A
></TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
><A
HREF=3D"intro.html"
>Next</A
></TD
></TR
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
>Linux NFS-HOWTO</TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
>&nbsp;</TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
>Introduction</TD
></TR
></TABLE
></DIV
></BODY
></HTML
>
--=-DzUZBAgzdIo18XiQgRt5
Content-Disposition: attachment; filename=performance.html
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html; charset=ISO-8859-1

<HTML
><HEAD
><TITLE
>Optimizing NFS Performance</TITLE
><META
NAME=3D"GENERATOR"
CONTENT=3D"Modular DocBook HTML Stylesheet Version 1.64
"><LINK
REL=3D"HOME"
TITLE=3D"Linux NFS-HOWTO"
HREF=3D"index.html"><LINK
REL=3D"PREVIOUS"
TITLE=3D"Setting up an NFS Client"
HREF=3D"client.html"><LINK
REL=3D"NEXT"
TITLE=3D"Security and NFS"
HREF=3D"security.html"></HEAD
><BODY
CLASS=3D"SECT1"
BGCOLOR=3D"#FFFFFF"
TEXT=3D"#000000"
LINK=3D"#0000FF"
VLINK=3D"#840084"
ALINK=3D"#0000FF"
><DIV
CLASS=3D"NAVHEADER"
><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TH
COLSPAN=3D"3"
ALIGN=3D"center"
>Linux NFS-HOWTO</TH
></TR
><TR
><TD
WIDTH=3D"10%"
ALIGN=3D"left"
VALIGN=3D"bottom"
><A
HREF=3D"client.html"
>Prev</A
></TD
><TD
WIDTH=3D"80%"
ALIGN=3D"center"
VALIGN=3D"bottom"
></TD
><TD
WIDTH=3D"10%"
ALIGN=3D"right"
VALIGN=3D"bottom"
><A
HREF=3D"security.html"
>Next</A
></TD
></TR
></TABLE
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"></DIV
><DIV
CLASS=3D"SECT1"
><H1
CLASS=3D"SECT1"
><A
NAME=3D"PERFORMANCE"
>5. Optimizing NFS Performance</A
></H1
><P
>Careful analysis of your environment, both from the client and from the se=
rver
point of view, is the first step necessary for optimal NFS performance. The
first sections will address issues that are generally important to the clie=
nt.
Later (<A
HREF=3D"performance.html#FRAG-OVERFLOW"
>Section 5.3</A
> and beyond), server side issues=20
will be discussed. In both
cases, these issues will not be limited exclusively to one side or the othe=
r,
but it is useful to separate the two in order to get a clearer picture of
cause and effect.</P
><P
>Aside from the general network configuration - appropriate network capacit=
y,
faster NICs, full duplex settings in order to reduce collisions, agreement =
in
network speed among the switches and hubs, etc. - one of the most important
client optimization settings are the NFS data transfer buffer sizes, specif=
ied
by the <B
CLASS=3D"COMMAND"
>mount</B
> command options <TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
>
and <TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
>.</P
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"BLOCKSIZES"
>5.1. Setting Block Size to Optimize Transfer Speeds</A
></H2
><P
>The <B
CLASS=3D"COMMAND"
>mount</B
> command options <TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
>=20
and <TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
> specify the size of the chunks of
data that the client and server pass back and forth=20
to each other. If no <TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
>
and <TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
> options are specified,=20
the default varies by which version of NFS we
are using. The most common default is 4K (4096 bytes), although for TCP-bas=
ed
mounts in 2.2 kernels, and for all mounts beginning with 2.4 kernels, the
server specifies the default block size.</P
><P
>The theoretical limit for the NFS V2 protocol is 8K. For the V3 protocol, =
the
limit is specific to the server. On the Linux server, the maximum block siz=
e
is defined by the value of the kernel constant=20
<TT
CLASS=3D"USERINPUT"
><B
>NFSSVC_MAXBLKSIZE</B
></TT
>, found in the
Linux kernel source file <TT
CLASS=3D"FILENAME"
>./include/linux/nfsd/const.h</TT
>.
The current maximum block size for the kernel, as of 2.4.17, is 8K (8192 by=
tes),
but the patch set implementing NFS over TCP/IP transport in the 2.4=20
series, as of this writing, uses a value of 32K (defined in the
patch as 32*1024) for the maximum block size.</P
><P
>All 2.4 clients currently support up to 32K block transfer sizes, allowing=
 the
standard 32K block transfers across NFS mounts from other servers, such as
Solaris, without client modification.</P
><P
>The defaults may be too big or too small, depending on the specific
combination of hardware and kernels. On the one hand, some combinations of
Linux kernels and network cards (largely on older machines) cannot handle
blocks that large. On the other hand, if they can handle larger blocks, a
bigger size might be faster.</P
><P
>You will want to experiment and find an <TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
>
and <TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
> that works and is as
fast as possible. You can test the speed of your options with some simple
commands, if your network environment is not heavily used. Note that your
results may vary widely unless you resort to using more complex benchmarks,
such as <SPAN
CLASS=3D"APPLICATION"
>Bonnie</SPAN
>, <SPAN
CLASS=3D"APPLICATION"
>Bonnie++</SPAN
>,
or <SPAN
CLASS=3D"APPLICATION"
>IOzone</SPAN
>.</P
><P
>The first of these commands transfers 16384 blocks of 16k each from the
special file <TT
CLASS=3D"FILENAME"
>/dev/zero</TT
> (which if=20
you read it just spits out zeros <EM
>really</EM
>
fast) to the mounted partition. We will time it to see how long it takes. S=
o,
from the client machine, type:</P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>    # time dd if=3D/dev/zero of=3D/mnt/home/testfile bs=3D16k count=3D1638=
4</PRE
></FONT
></TD
></TR
></TABLE
><P
>This creates a 256Mb file of zeroed bytes. In general, you should create a
file that's at least twice as large as the system RAM on the server, but ma=
ke
sure you have enough disk space! Then read back the file into the great bla=
ck
hole on the client machine (<TT
CLASS=3D"FILENAME"
>/dev/null</TT
>) by=20
typing the following:</P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>    # time dd if=3D/mnt/home/testfile of=3D/dev/null bs=3D16k</PRE
></FONT
></TD
></TR
></TABLE
><P
>Repeat this a few times and average how long it takes. Be sure to unmount =
and
remount the filesystem each time (both on the client and, if you are zealou=
s,
locally on the server as well), which should clear out any caches.</P
><P
>Then unmount, and mount again with a larger and smaller block size. They
should be multiples of 1024, and not larger than the maximum block size
allowed by your system. Note that NFS Version 2 is limited to a maximum of =
8K,
regardless of the maximum block size defined by=20
<TT
CLASS=3D"USERINPUT"
><B
>NFSSVC_MAXBLKSIZE</B
></TT
>; Version 3
will support up to 64K, if permitted. The block size should be a power of t=
wo
since most of the parameters that would constrain it (such as file system
block sizes and network packet size) are also powers of two. However, some
users have reported better successes with block sizes that are not powers o=
f
two but are still multiples of the file system block size and the network
packet size.</P
><P
>Directly after mounting with a larger size, cd into the mounted
file system and do things like <B
CLASS=3D"COMMAND"
>ls</B
>, explore=20
the filesystem a bit to make sure everything is as it
should. If the <TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
>/<TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
>
 is too large the symptoms are very odd and not 100%
obvious. A typical symptom is incomplete file lists when doing=20
<B
CLASS=3D"COMMAND"
>ls</B
>, and no
error messages, or reading files failing mysteriously with no error message=
s.
After establishing that the given <TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
>/
<TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
> works you can do the speed tests
again. Different server platforms are likely to have different optimal size=
s.</P
><P
>Remember to edit <TT
CLASS=3D"FILENAME"
>/etc/fstab</TT
> to reflect the=20
<TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
>/<TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
> you found
to be the most desirable.</P
><P
>If your results seem inconsistent, or doubtful, you may need to analyze yo=
ur
network more extensively while varying the <TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
>
and <TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
> values. In that
case, here are several pointers to benchmarks that may prove useful:</P
><P
></P
><UL
><LI
><P
>     Bonnie                            <A
HREF=3D"http://www.textuality.com/bonnie/"
TARGET=3D"_top"
>http://www.textuality.com/bonnie/</A
></P
></LI
><LI
><P
>     Bonnie++                          <A
HREF=3D"http://www.coker.com.au/bonnie++/"
TARGET=3D"_top"
>http://www.coker.com.au/bonnie++/</A
></P
></LI
><LI
><P
>     IOzone file system benchmark      <A
HREF=3D"http://www.iozone.org/"
TARGET=3D"_top"
>http://www.iozone.org/</A
></P
></LI
><LI
><P
>     The official NFS benchmark,
     SPECsfs97                         <A
HREF=3D"http://www.spec.org/osg/sfs97/"
TARGET=3D"_top"
>http://www.spec.org/osg/sfs97/</A
></P
></LI
></UL
><P
>The easiest benchmark with the widest coverage, including an extensive spr=
ead
of file sizes, and of IO types - reads, &#38; writes, rereads &#38; rewrite=
s, random
access, etc. - seems to be IOzone. A recommended invocation of IOzone (for
which you must have root privileges) includes unmounting and remounting the
directory under test, in order to clear out the caches between tests, and
including the file close time in the measurements. Assuming you've already
exported <TT
CLASS=3D"FILENAME"
>/tmp</TT
> to everyone from the server
<TT
CLASS=3D"COMPUTEROUTPUT"
>foo</TT
>,=20
and that you've installed IOzone in the local directory, this should work:<=
/P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>    # echo "foo:/tmp /mnt/foo nfs rw,hard,intr,rsize=3D8192,wsize=3D8192 0=
 0"
    &#62;&#62; /etc/fstab
    # mkdir /mnt/foo
    # mount /mnt/foo
    # ./iozone -a -R -c -U /mnt/foo -f /mnt/foo/testfile &#62; logfile</PRE
></FONT
></TD
></TR
></TABLE
><P
>The benchmark should take 2-3 hours at most, but of course you will need t=
o
run it for each value of rsize and wsize that is of interest. The web site
gives full documentation of the parameters, but the specific options used
above are:</P
><P
></P
><UL
><LI
><P
>     <TT
CLASS=3D"USERINPUT"
><B
>-a</B
></TT
> Full automatic mode, which tests file sizes of 64K to 512M, using
     record sizes of 4K to 16M</P
></LI
><LI
><P
>     <TT
CLASS=3D"USERINPUT"
><B
>-R</B
></TT
> Generate report in excel spreadsheet form (The "surface plot"
     option for graphs is best)</P
></LI
><LI
><P
>     <TT
CLASS=3D"USERINPUT"
><B
>-c</B
></TT
> Include the file close time in the tests, which will pick up the
     NFS version 3 commit time</P
></LI
><LI
><P
>     <TT
CLASS=3D"USERINPUT"
><B
>-U</B
></TT
> Use the given mount point to unmount and remount between tests;
     it clears out caches</P
></LI
><LI
><P
>     <TT
CLASS=3D"USERINPUT"
><B
>-f</B
></TT
> When using unmount, you have to locate the test file in the
     mounted file system</P
></LI
></UL
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"PACKET-AND-NETWORK"
>5.2. Packet Size and Network Drivers</A
></H2
><P
>  While many Linux network card drivers are excellent, some are quite shod=
dy,
  including a few drivers for some fairly standard cards.  It is worth
  experimenting with your network card directly to find out how it can
  best handle traffic.</P
><P
>   Try <B
CLASS=3D"COMMAND"
>ping</B
>ing back and forth=20
   between the two machines with large packets using
   the <TT
CLASS=3D"USERINPUT"
><B
>-f</B
></TT
> and <TT
CLASS=3D"USERINPUT"
><B
>-s</B
></TT
>
   options with <B
CLASS=3D"COMMAND"
>ping</B
> (see <EM
>ping(8)</EM
>=20
   for more details) and see if a
   lot of packets get dropped, or if they take a long time for a reply. If =
so,
   you may have a problem with the performance of your network card.</P
><P
>For a more extensive analysis of NFS behavior in particular, use the <B
CLASS=3D"COMMAND"
>nfsstat</B
> command to look at nfs transactions, client and server statistics, networ=
k
statistics, and so forth. The <TT
CLASS=3D"USERINPUT"
><B
>"-o net"</B
></TT
> option will show you the number of
dropped packets in relation to the total number of transactions. In UDP
transactions, the most important statistic is the number of retransmissions=
,
due to dropped packets, socket buffer overflows, general server congestion,
timeouts, etc. This will have a tremendously important effect on NFS
performance, and should be carefully monitored. Note that nfsstat does not =
yet
implement the <TT
CLASS=3D"USERINPUT"
><B
>-z</B
></TT
> option, which would zero out all counters, so you must look
at the current <B
CLASS=3D"COMMAND"
>nfsstat</B
> counter values prior to running the benchmarks.</P
><P
>To correct network problems, you may wish to reconfigure the packet size t=
hat
your network card uses. Very often there is a constraint somewhere else in =
the
network (such as a router) that causes a smaller maximum packet size betwee=
n
two machines than what the network cards on the machines are actually capab=
le
of. TCP should autodiscover the appropriate packet size for a network, but =
UDP
will simply stay at a default value. So determining the appropriate packet
size is especially important if you are using NFS over UDP.</P
><P
>You can test for the network packet size using the <B
CLASS=3D"COMMAND"
>tracepath</B
> command: From
the client machine, just type <TT
CLASS=3D"USERINPUT"
><B
>tracepath</B
></TT
>=20
<EM
>server</EM
> <TT
CLASS=3D"USERINPUT"
><B
>2049</B
></TT
> and the path MTU should
be reported at the bottom. You can then set the MTU on your network card eq=
ual
to the path MTU, by using the <TT
CLASS=3D"USERINPUT"
><B
>MTU</B
></TT
>=20
option to <B
CLASS=3D"COMMAND"
>ifconfig</B
>, and see if fewer packets
get dropped. See the <B
CLASS=3D"COMMAND"
>ifconfig</B
> man pages for details on how to reset the MTU.</P
><P
>In addition, <B
CLASS=3D"COMMAND"
>netstat -s</B
> will give the statistics collected for traffic across
all supported protocols. You may also look at=20
<TT
CLASS=3D"FILENAME"
>/proc/net/snmp</TT
> for information
about current network behavior; see the next section for more details.</P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"FRAG-OVERFLOW"
>5.3. Overflow of Fragmented Packets</A
></H2
><P
>Using an <TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
> or <TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
>=20
larger than your network's MTU (often set to 1500, in
many networks) will cause IP packet fragmentation when using NFS over UDP. =
IP
packet fragmentation and reassembly require a significant amount of CPU
resource at both ends of a network connection. In addition, packet
fragmentation also exposes your network traffic to greater unreliability,
since a complete RPC request must be retransmitted if a UDP packet fragment=
 is
dropped for any reason. Any increase of RPC retransmissions, along with the
possibility of increased timeouts, are the single worst impediment to
performance for NFS over UDP.</P
><P
>Packets may be dropped for many reasons. If your network topography is
complex, fragment routes may differ, and may not all arrive at the Server f=
or
reassembly. NFS Server capacity may also be an issue, since the kernel has =
a
limit of how many fragments it can buffer before it starts throwing away
packets. With kernels that support the <TT
CLASS=3D"FILENAME"
>/proc</TT
>=20
filesystem, you can monitor the
files <TT
CLASS=3D"FILENAME"
>/proc/sys/net/ipv4/ipfrag_high_thresh</TT
> and
<TT
CLASS=3D"FILENAME"
>/proc/sys/net/ipv4/ipfrag_low_thresh</TT
>. Once the number of unprocessed,
fragmented packets reaches the number specified by <TT
CLASS=3D"FILENAME"
>ipfrag_high_thresh</TT
> (in
bytes), the kernel will simply start throwing away fragmented packets until
the number of incomplete packets reaches the number specified by
<TT
CLASS=3D"FILENAME"
>ipfrag_low_thresh.</TT
></P
><P
>Another counter to monitor is <TT
CLASS=3D"USERINPUT"
><B
>IP: ReasmFails</B
></TT
>=20
in the file <TT
CLASS=3D"FILENAME"
>/proc/net/snmp</TT
>; this
is the number of fragment reassembly failures. if it goes up too quickly
during heavy file activity, you may have problem.</P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"NFS-TCP"
>5.4. NFS over TCP</A
></H2
><P
>A new feature, available for both 2.4 and 2.5 kernels but not yet
integrated into the mainstream kernel at the time of=20
this writing, is NFS over TCP. Using TCP
has a distinct advantage and a distinct disadvantage over UDP.  The advanta=
ge
is that it works far better than UDP on lossy networks.
When using TCP, a single dropped packet can be retransmitted, without
the retransmission of the entire RPC request, resulting in better performan=
ce
on lossy networks. In addition, TCP will handle network speed differences
better than UDP, due to the underlying flow control at the network level. <=
/P
><P
>The disadvantage of using TCP is that it is not a stateless protocol like
UDP.  If your server crashes in the middle of a packet transmission,
the client will hang and any shares will need to be unmounted and remounted=
.</P
><P
>The overhead incurred by the TCP protocol will result in
somewhat slower performance than UDP under ideal network
conditions, but the cost is not severe, and is often not
noticable without careful measurement. If you are using=20
gigabit ethernet from end to end, you might also investigate the
usage of jumbo frames, since the high speed network may
allow the larger frame sizes without encountering increased=20
collision rates, particularly if you have set the network=20
to full duplex.</P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"TIMEOUT"
>5.5. Timeout and Retransmission Values</A
></H2
><P
>Two mount command options, <TT
CLASS=3D"USERINPUT"
><B
>timeo</B
></TT
>=20
and <TT
CLASS=3D"USERINPUT"
><B
>retrans</B
></TT
>, control the behavior of UDP
requests when encountering client timeouts due to dropped packets, network
congestion, and so forth. The <TT
CLASS=3D"USERINPUT"
><B
>-o timeo</B
></TT
>=20
option allows designation of the length
of time, in tenths of seconds, that the client will wait until it decides i=
t
will not get a reply from the server, and must try to send the request agai=
n.
The default value is 7 tenths of a second. The=20
<TT
CLASS=3D"USERINPUT"
><B
>-o retrans</B
></TT
> option allows
designation of the number of timeouts allowed before the client gives up, a=
nd
displays the <TT
CLASS=3D"COMPUTEROUTPUT"
>Server not responding</TT
>=20
message. The default value is 3 attempts.
Once the client displays this message, it will continue to try to send
the request, but only once before displaying the error message if
another timeout occurs.  When the client reestablishes contact, it=20
will fall back to using the correct <TT
CLASS=3D"USERINPUT"
><B
>retrans</B
></TT
>=20
value, and will display the <TT
CLASS=3D"COMPUTEROUTPUT"
>Server OK</TT
> message.</P
><P
>If you are already encountering excessive retransmissions (see the output =
of
the <B
CLASS=3D"COMMAND"
>nfsstat</B
> command), or want to increase the block transfer size without
encountering timeouts and retransmissions, you may want to adjust these
values. The specific adjustment will depend upon your environment, and in m=
ost
cases, the current defaults are appropriate.</P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"NFSD-INSTANCE"
>5.6. Number of Instances of the NFSD Server Daemon</A
></H2
><P
>Most startup scripts, Linux and otherwise, start 8 instances of=20
<B
CLASS=3D"COMMAND"
>nfsd</B
>. In the
early days of NFS, Sun decided on this number as a rule of thumb, and every=
one
else copied. There are no good measures of how many instances are optimal, =
but
a more heavily-trafficked server may require more. If you are using a 2.4 o=
r
higher kernel and you want to see how heavily each=20
<B
CLASS=3D"COMMAND"
>nfsd</B
> thread is being used,
you can look at the file <TT
CLASS=3D"FILENAME"
>/proc/net/rpc/nfsd</TT
>.
The last ten numbers on the <TT
CLASS=3D"USERINPUT"
><B
>th</B
></TT
>
line in that file indicate the number of seconds that the thread usage was =
at
that percentage of the maximum allowable. If you have a large number in the
top three deciles, you may wish to increase the number=20
of <B
CLASS=3D"COMMAND"
>nfsd</B
> instances. This
is done upon starting <B
CLASS=3D"COMMAND"
>nfsd</B
> using the
number of instances as the command line
option, and is specified in the NFS startup script=20
(<TT
CLASS=3D"FILENAME"
>/etc/rc.d/init.d/nfs</TT
> on
Red Hat) as <TT
CLASS=3D"USERINPUT"
><B
>RPCNFSDCOUNT</B
></TT
>.=20
See the <EM
>nfsd(8)</EM
> man page for more information.</P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"MEMLIMITS"
>5.7. Memory Limits on the Input Queue</A
></H2
><P
>On 2.2 and 2.4 kernels, the socket input queue, where requests sit while t=
hey
are currently being processed, has a small default size limit (<TT
CLASS=3D"FILENAME"
>rmem_default</TT
>)
of 64k. This queue is important for clients with heavy read loads, and serv=
ers
with heavy write loads. As an example, if you are running 8 instances of nf=
sd
on the server, each will only have 8k to store write requests while it
processes them. In addition, the socket output queue - important for client=
s
with heavy write loads and servers with heavy read loads - also has a small
default size (<TT
CLASS=3D"FILENAME"
>wmem_default</TT
>).</P
><P
>Several published runs of the NFS benchmark=20
<A
HREF=3D"http://www.spec.org/osg/sfs97/"
TARGET=3D"_top"
>SPECsfs</A
>=20
specify usage of a much higher value for both
the read and write value sets, <TT
CLASS=3D"FILENAME"
>[rw]mem_default</TT
> and=20
<TT
CLASS=3D"FILENAME"
>[rw]mem_max</TT
>. You might
consider increasing these values to at least 256k. The read and write limit=
s
are set in the proc file system using (for example) the files
<TT
CLASS=3D"FILENAME"
>/proc/sys/net/core/rmem_default</TT
> and=20
<TT
CLASS=3D"FILENAME"
>/proc/sys/net/core/rmem_max</TT
>. The
<TT
CLASS=3D"FILENAME"
>rmem_default</TT
> value can be increased in three steps; the following method is a
bit of a hack but should work and should not cause any problems:</P
><P
></P
><UL
><LI
><P
>     Increase the size listed in the file:</P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"90%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>     # echo 262144 &#62; /proc/sys/net/core/rmem_default
     # echo 262144 &#62; /proc/sys/net/core/rmem_max</PRE
></FONT
></TD
></TR
></TABLE
></LI
><LI
><P
>     Restart NFS.  For example, on Red Hat systems,</P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"90%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>     # /etc/rc.d/init.d/nfs restart</PRE
></FONT
></TD
></TR
></TABLE
></LI
><LI
><P
>     You might return the size limits to their normal size in case other
     kernel systems depend on it:</P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"90%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>     # echo 65536 &#62; /proc/sys/net/core/rmem_default
     # echo 65536 &#62; /proc/sys/net/core/rmem_max</PRE
></FONT
></TD
></TR
></TABLE
></LI
></UL
><P
>     This last step may be necessary because machines have been reported t=
o
     crash if these values are left changed for long periods of time.</P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"AUTONEGOTIATION"
>5.8. Turning Off Autonegotiation of NICs and Hubs</A
></H2
><P
>If network cards auto-negotiate badly with hubs and switches, and ports ru=
n at
different speeds, or with different duplex configurations, performance will=
 be
severely impacted due to excessive collisions, dropped packets, etc. If you
see excessive numbers of dropped packets in the nfsstat output, or poor
network performance in general, try playing around with the network speed a=
nd
duplex settings. If possible, concentrate on establishing a 100BaseT full
duplex subnet; the virtual elimination of collisions in full duplex will
remove the most severe performance inhibitor for NFS over UDP.  Be careful
when turning off autonegotiation on a card: The hub or switch that the card
is attached to will then resort to other mechanisms (such as parallel detec=
tion)
to determine the duplex settings, and some cards default to half duplex
because it is more likely to be supported by an old hub.  The best solution=
,=20
if the driver supports it, is to force the card to negotiate 100BaseT=20
full duplex.</P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SYNC-ASYNC"
>5.9. Synchronous vs. Asynchronous Behavior in NFS</A
></H2
><P
>The default export behavior for both NFS Version 2 and Version 3 protocols=
,
used by <B
CLASS=3D"COMMAND"
>exportfs</B
> in <SPAN
CLASS=3D"APPLICATION"
>nfs-utils</SPAN
>=20
versions prior to Version 1.11 (the latter is in the CVS tree,=20
but not yet released in a package, as of January, 2002) is
"asynchronous". This default permits the server to reply to client requests=
 as
soon as it has processed the request and handed it off to the local file
system, without waiting for the data to be written to stable storage. This =
is
indicated by the <TT
CLASS=3D"USERINPUT"
><B
>async</B
></TT
> option denoted in the server's export list. It yields
better performance at the cost of possible data corruption if the server
reboots while still holding unwritten data and/or metadata in its caches. T=
his
possible data corruption is not detectable at the time of occurrence, since
the <TT
CLASS=3D"USERINPUT"
><B
>async</B
></TT
> option instructs the server to lie to the client, telling the
client that all data has indeed been written to the stable storage, regardl=
ess
of the protocol used.</P
><P
>In order to conform with "synchronous" behavior, used as the default for m=
ost
proprietary systems supporting NFS (Solaris, HP-UX, RS/6000, etc.), and now
used as the default in the latest version of <B
CLASS=3D"COMMAND"
>exportfs</B
>, the Linux Server's
file system must be exported with the <TT
CLASS=3D"USERINPUT"
><B
>sync</B
></TT
> option. Note that specifying
synchronous exports will result in no option being seen in the server's exp=
ort
list:</P
><P
></P
><UL
><LI
><P
>     Export a couple file systems to everyone, using slightly different
     options:</P
><P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"90%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>    # /usr/sbin/exportfs -o rw,sync *:/usr/local
    # /usr/sbin/exportfs -o rw *:/tmp</PRE
></FONT
></TD
></TR
></TABLE
></P
></LI
><LI
><P
>     Now we can see what the exported file system parameters look like:</P
><P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"90%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>    # /usr/sbin/exportfs -v
    /usr/local *(rw)
    /tmp *(rw,async)</PRE
></FONT
></TD
></TR
></TABLE
></P
></LI
></UL
><P
>If your kernel is compiled with the <TT
CLASS=3D"FILENAME"
>/proc</TT
> filesystem,
then the file <TT
CLASS=3D"FILENAME"
>/proc/fs/nfs/exports</TT
> will also show the
full list of export options.</P
><P
>When synchronous behavior is specified, the server will not complete (that=
 is,
reply to the client) an NFS version 2 protocol request until the local file
system has written all data/metadata to the disk. The server
<EM
>will</EM
> complete a
synchronous NFS version 3 request without this delay, and will return the
status of the data in order to inform the client as to what data should be
maintained in its caches, and what data is safe to discard. There are 3
possible status values, defined an enumerated type, <TT
CLASS=3D"USERINPUT"
><B
>nfs3_stable_how</B
></TT
>, in
<TT
CLASS=3D"FILENAME"
>include/linux/nfs.h</TT
>. The values, along with the subsequent actions taken due
to these results, are as follows:</P
><P
></P
><UL
><LI
><P
>NFS_UNSTABLE - Data/Metadata was not committed to stable storage on the
server, and must be cached on the client until a subsequent client commit
request assures that the server does send data to stable storage.</P
></LI
><LI
><P
>NFS_DATA_SYNC - Metadata was not sent to stable storage, and must be cache=
d
on the client. A subsequent commit is necessary, as is required above.</P
></LI
><LI
><P
>NFS_FILE_SYNC - No data/metadata need be cached, and a subsequent commit
need not be sent for the range covered by this request.</P
></LI
></UL
><P
>In addition to the above definition of synchronous behavior, the client ma=
y
explicitly insist on total synchronous behavior, regardless of the protocol=
,
by opening all files with the <TT
CLASS=3D"USERINPUT"
><B
>O_SYNC</B
></TT
> option. In this case, all replies to
client requests will wait until the data has hit the server's disk, regardl=
ess
of the protocol used (meaning that, in NFS version 3, all requests will be
<TT
CLASS=3D"USERINPUT"
><B
>NFS_FILE_SYNC</B
></TT
> requests, and will require that the Server returns this status).
In that case, the performance of NFS Version 2 and NFS Version 3 will be
virtually identical.</P
><P
>If, however, the old default <TT
CLASS=3D"USERINPUT"
><B
>async</B
></TT
>=20
behavior is used, the <TT
CLASS=3D"USERINPUT"
><B
>O_SYNC</B
></TT
> option has
no effect at all in either version of NFS, since the server will reply to t=
he
client without waiting for the write to complete. In that case the performa=
nce
differences between versions will also disappear.</P
><P
>Finally, note that, for NFS version 3 protocol requests, a subsequent comm=
it
request from the NFS client at file close time, or at <B
CLASS=3D"COMMAND"
>fsync()</B
> time, will force
the server to write any previously unwritten data/metadata to the disk, and
the server will not reply to the client until this has been completed, as l=
ong
as <TT
CLASS=3D"USERINPUT"
><B
>sync</B
></TT
> behavior is followed. If <TT
CLASS=3D"USERINPUT"
><B
>async</B
></TT
> is used, the commit is essentially
a no-op, since the server once again lies to the client, telling the client=
 that
the data has been sent to stable storage. This again exposes the client and
server to data corruption, since cached data may be discarded on the client
due to its belief that the server now has the data maintained in stable
storage.</P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"NON-NFS-PERFORMANCE"
>5.10. Non-NFS-Related Means of Enhancing Server Performance</A
></H2
><P
>In general, server performance and server disk access speed will have an
important effect on NFS performance.
Offering general guidelines for setting up a well-functioning file server i=
s
outside the scope of this document, but a few hints may be worth mentioning=
:</P
><P
></P
><UL
><LI
><P
>If you have access to RAID arrays, use RAID 1/0 for both write speed and
redundancy; RAID 5 gives you good read speeds but lousy write speeds.</P
></LI
><LI
><P
>A journalling filesystem will drastically reduce your reboot time in the
event of a system crash. Currently,
<A
HREF=3D"ftp://ftp.uk.linux.org/pub/linux/sct/fs/jfs/"
TARGET=3D"_top"
>ext3</A
> will work correctly with NFS
version 3. In addition, Reiserfs version 3.6 will work with NFS version 3 o=
n
2.4.7 or later kernels (patches are available for previous kernels). Earlie=
r versions
of Reiserfs did not include room for generation numbers in the inode, expos=
ing
the possibility of undetected data corruption during a server reboot.</P
></LI
><LI
><P
>Additionally, journalled file systems can be configured to maximize
performance by taking advantage of the fact that journal updates are all th=
at
is necessary for data protection. One example is using ext3 with <TT
CLASS=3D"USERINPUT"
><B
>data=3Djournal</B
></TT
>
so that all updates go first to the journal, and later to the main file
system. Once the journal has been updated, the NFS server can safely issue =
the
reply to the clients, and the main file system update can occur at the
server's leisure.</P
><P
>The journal in a journalling file system may also reside on a separate dev=
ice
such as a flash memory card so that journal updates normally require no see=
king. With only rotational
delay imposing a cost, this gives reasonably good synchronous IO performanc=
e.
Note that ext3 currently supports journal relocation, and ReiserFS will
(officially) support it soon. The Reiserfs tool package found at <A
HREF=3D"ftp://ftp.namesys.com/pub/reiserfsprogs/reiserfsprogs-3.x.0k.tar.gz=
"
TARGET=3D"_top"
>ftp://ftp.namesys.com/pub/reiserfsprogs/reiserfsprogs-3.x.0k.tar.gz </A
>
contains
the <B
CLASS=3D"COMMAND"
>reiserfstune</B
> tool, which will allow journal relocation. It does, however,
require a kernel patch which has not yet been officially released as of
January, 2002.</P
></LI
><LI
><P
>Using an automounter (such as <SPAN
CLASS=3D"APPLICATION"
>autofs</SPAN
> or <SPAN
CLASS=3D"APPLICATION"
>amd</SPAN
>) may prevent hangs if you
cross-mount files on your machines (whether on purpose or by oversight) and
one of those machines goes down. See the <A
HREF=3D"http://www.linuxdoc.org/HOWTO/mini/Automount.html"
TARGET=3D"_top"
>Automount Mini-HOWTO</A
> for details.</P
></LI
><LI
><P
>Some manufacturers (Network Appliance, Compaq, and others) provide NFS
accelerators in the form of Non-Volatile RAM. NVRAM will boost access speed=
 to
stable storage up to the equivalent of <TT
CLASS=3D"USERINPUT"
><B
>async</B
></TT
> access.</P
></LI
></UL
></DIV
></DIV
><DIV
CLASS=3D"NAVFOOTER"
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
><A
HREF=3D"client.html"
>Prev</A
></TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
><A
HREF=3D"index.html"
>Home</A
></TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
><A
HREF=3D"security.html"
>Next</A
></TD
></TR
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
>Setting up an NFS Client</TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
>&nbsp;</TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
>Security and NFS</TD
></TR
></TABLE
></DIV
></BODY
></HTML
>
--=-DzUZBAgzdIo18XiQgRt5
Content-Disposition: attachment; filename=security.html
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html; charset=ISO-8859-1

<HTML
><HEAD
><TITLE
>Security and NFS</TITLE
><META
NAME=3D"GENERATOR"
CONTENT=3D"Modular DocBook HTML Stylesheet Version 1.64
"><LINK
REL=3D"HOME"
TITLE=3D"Linux NFS-HOWTO"
HREF=3D"index.html"><LINK
REL=3D"PREVIOUS"
TITLE=3D"Optimizing NFS Performance"
HREF=3D"performance.html"><LINK
REL=3D"NEXT"
TITLE=3D"Troubleshooting"
HREF=3D"troubleshooting.html"></HEAD
><BODY
CLASS=3D"SECT1"
BGCOLOR=3D"#FFFFFF"
TEXT=3D"#000000"
LINK=3D"#0000FF"
VLINK=3D"#840084"
ALINK=3D"#0000FF"
><DIV
CLASS=3D"NAVHEADER"
><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TH
COLSPAN=3D"3"
ALIGN=3D"center"
>Linux NFS-HOWTO</TH
></TR
><TR
><TD
WIDTH=3D"10%"
ALIGN=3D"left"
VALIGN=3D"bottom"
><A
HREF=3D"performance.html"
>Prev</A
></TD
><TD
WIDTH=3D"80%"
ALIGN=3D"center"
VALIGN=3D"bottom"
></TD
><TD
WIDTH=3D"10%"
ALIGN=3D"right"
VALIGN=3D"bottom"
><A
HREF=3D"troubleshooting.html"
>Next</A
></TD
></TR
></TABLE
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"></DIV
><DIV
CLASS=3D"SECT1"
><H1
CLASS=3D"SECT1"
><A
NAME=3D"SECURITY"
>6. Security and NFS</A
></H1
><P
>   This list of security tips and explanations will not make your site=20
   completely secure. <EM
>NOTHING</EM
> will make your site completely secure. Reading this section
   may help you get an idea of the security problems with NFS. This is not=20
   a comprehensive guide and it will always be undergoing changes. If you=20
   have any tips or hints to give us please send them to the HOWTO=20
   maintainer.
 </P
><P
>   If you are on a network with no access to the outside world (not even a=
=20
   modem) and you trust all the internal machines and all your users then=20
   this section will be of no use to you.  However, its our belief that=20
   there are relatively few networks in this situation so we would suggest=20
   reading this section thoroughly for anyone setting up NFS.
 </P
><P
>   With NFS, there are two steps required for a client to gain access to=20
   a file contained in a remote directory on the server. The first step is =
mount
   access. Mount access is achieved by the client machine attempting to=20
   attach to the server. The security for this is provided by the=20
   <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> file. This file lists the names or IP addresses for machines
   that are allowed to access a share point. If the client's ip address=20
   matches one of the entries in the access list then it will be allowed to
   mount. This is not terribly secure. If someone is capable of spoofing or
   taking over a trusted address then they can access your mount points. To
   give a real-world example of this type of "authentication": This is=20
   equivalent to someone introducing themselves to you and you believing th=
ey
   are who they claim to be because they are wearing a sticker that says
   "Hello, My Name is ...."  Once the machine has mounted a volume, its
   operating system will have access to all files on the volume (with the
   possible exception of those owned by root; see below) and write access
   to those files as well, if the volume was exported with the=20
   <TT
CLASS=3D"USERINPUT"
><B
>rw</B
></TT
> option.
 </P
><P
>   The second step is file access. This is a function of normal file syste=
m
   access controls on the client and not a specialized function of NFS.=20
   Once the drive is mounted the user and group permissions on the files
   determine access control.=20
 </P
><P
>   An example: bob on the server maps to the UserID 9999. Bob
   makes a file on the server that is only accessible the user=20
   (the equivalent to typing=20
   <TT
CLASS=3D"USERINPUT"
><B
>chmod 600</B
></TT
> <EM
>filename</EM
>).
   A client is allowed to mount the drive where the file is stored.
   On the client mary maps to UserID 9999. This means that the client
   user mary can access bob's file that is marked as only accessible by him=
.
   It gets worse: If someone has become superuser on the client machine the=
y can
   <B
CLASS=3D"COMMAND"
>su - </B
> <EM
>username</EM
>=20
   and become <EM
>any</EM
> user. NFS will be none the wiser.=20
 </P
><P
>   Its not all terrible. There are a few measures you can take on the serv=
er
   to offset the danger of the clients. We will cover those shortly.
 </P
><P
>   If you don't think the security measures apply to you, you're probably
   wrong. In <A
HREF=3D"security.html#PORTMAPPER-SECURITY"
>Section 6.1</A
> we'll cover securing the portmapper,=20
   server and client security in <A
HREF=3D"security.html#SERVER.SECURITY"
>Section 6.2</A
> and <A
HREF=3D"security.html#CLIENT.SECURITY"
>Section 6.3</A
> respectively.=20
   Finally, in <A
HREF=3D"security.html#FIREWALLS"
>Section 6.4</A
> we'll briefly talk about proper firewalling for
   your nfs server.=20
 </P
><P
>   Finally, it is critical that all of your nfs daemons and client program=
s
   are current. If you think that a flaw is too recently announced for it t=
o
   be a problem for you, then you've probably already been compromised.
 </P
><P
>   A good way to keep up to date on security alerts is to subscribe to the=
=20
   bugtraq mailinglists.  You can read up on how to subscribe and various=20
   other information about bugtraq here:  =20
=20
  <A
HREF=3D"http://www.securityfocus.com/forums/bugtraq/faq.html"
TARGET=3D"_top"
>http://www.securityfocus.com/forums/bugtraq/faq.html</A
>
 </P
><P
>   Additionally searching for <EM
>NFS</EM
> at=20
   <A
HREF=3D"http://www.securityfocus.com"
TARGET=3D"_top"
>securityfocus.com's</A
> search engine will
   show you all security reports pertaining to NFS.
 </P
><P
>  You should also regularly check CERT advisories.  See the CERT web page
  at <A
HREF=3D"http://www.cert.org"
TARGET=3D"_top"
>www.cert.org</A
>.
 </P
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"PORTMAPPER-SECURITY"
>6.1. The portmapper</A
></H2
><P
>    The portmapper keeps a list of what services are running on what ports=
.
    This list is used by a connecting machine to see what ports it wants to
    talk to access certain services.=20
  </P
><P
> =20
    The portmapper is not in as bad a shape as a few years ago but it is
    still a point of worry for many sys admins.  The portmapper, like NFS a=
nd
    NIS, should not really have connections made to it outside of a trusted
    local area network. If you have to expose them to the outside world -=20
    be careful and keep up diligent monitoring of those systems.
  </P
><P
>    Not all Linux distributions were created equal.  Some seemingly up-to-=
date=20
    distributions do not include a securable portmapper.=20
    The easy way to check if your portmapper is good or not is to run=20
    <EM
>strings(1)</EM
> and see if it reads the relevant files, <TT
CLASS=3D"FILENAME"
>/etc/hosts.deny</TT
> and
    <TT
CLASS=3D"FILENAME"
>/etc/hosts.allow</TT
>.  Assuming your portmapper is <TT
CLASS=3D"FILENAME"
>/sbin/portmap</TT
> you can=20
    check it with this command:=20
     <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>     strings /sbin/portmap | grep hosts. =20
     </PRE
></FONT
></TD
></TR
></TABLE
>
   </P
><P
>     On a securable machine it comes up something like this:
  <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>   /etc/hosts.allow
   /etc/hosts.deny
   @(#) hosts_ctl.c 1.4 94/12/28 17:42:27
   @(#) hosts_access.c 1.21 97/02/12 02:13:22
  </PRE
></FONT
></TD
></TR
></TABLE
>
  </P
><P
>   First we edit <TT
CLASS=3D"FILENAME"
>/etc/hosts.deny</TT
>.  It should contain the line
  </P
><P
>  <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>   portmap: ALL
  </PRE
></FONT
></TD
></TR
></TABLE
>
  </P
><P
>    which will deny access to everyone.  While it is closed run:
  <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>   rpcinfo -p
  </PRE
></FONT
></TD
></TR
></TABLE
>
    just to check that your portmapper really reads and obeys
    this file.  Rpcinfo should give no output, or possibly an error message=
.
    The files <TT
CLASS=3D"FILENAME"
>/etc/hosts.allow</TT
> and <TT
CLASS=3D"FILENAME"
>/etc/hosts.deny</TT
>
    take effect immediately after you save them. No daemon needs to be rest=
arted.
  </P
><P
>    Closing the portmapper for everyone is a bit drastic, so we open it
    again by editing <TT
CLASS=3D"FILENAME"
>/etc/hosts.allow</TT
>.  But first=20
    we need to figure out what to put in it.  It should basically list=20
    all machines that should  have access to your portmapper.  On a run of=20
    the mill Linux system there are very few machines that need any access=20
    for any reason.  The portmapper administers <B
CLASS=3D"COMMAND"
>nfsd</B
>,=20
    <B
CLASS=3D"COMMAND"
>mountd</B
>, <B
CLASS=3D"COMMAND"
>ypbind</B
>/<B
CLASS=3D"COMMAND"
>ypserv</B
>,
    <B
CLASS=3D"COMMAND"
>rquotad</B
>, <B
CLASS=3D"COMMAND"
>lockd</B
> (which shows up
    as <TT
CLASS=3D"COMPUTEROUTPUT"
>nlockmgr</TT
>), <B
CLASS=3D"COMMAND"
>statd</B
>
    (which shows up as <TT
CLASS=3D"COMPUTEROUTPUT"
>status</TT
>)=20
    and 'r' services like <B
CLASS=3D"COMMAND"
>ruptime</B
>=20
    and <B
CLASS=3D"COMMAND"
>rusers</B
>.
    Of these only <B
CLASS=3D"COMMAND"
>nfsd</B
>, <B
CLASS=3D"COMMAND"
>mountd</B
>,=20
    <B
CLASS=3D"COMMAND"
>ypbind</B
>/<B
CLASS=3D"COMMAND"
>ypserv</B
> and perhaps=20
    <B
CLASS=3D"COMMAND"
>rquotad</B
>,<B
CLASS=3D"COMMAND"
>lockd</B
>=20
    and <B
CLASS=3D"COMMAND"
>statd</B
> are of any consequence.  All machines that need=20
    to access services on your machine should be allowed to do that.  Let's=
=20
    say that your machine's address is <EM
>192.168.0.254</EM
> and=20
    that it lives on the subnet <EM
>192.168.0.0</EM
>, and that all=20
    machines on the subnet should have access to it (for an overview of tho=
se
    terms see the the <A
HREF=3D"http://www.linuxdoc.org/HOWTO/Networking-Overview-HOWTO.html"
TARGET=3D"_top"
>Networking-Overview-HOWTO</A
>).  Then we write:
   <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>   portmap: 192.168.0.0/255.255.255.0
   </PRE
></FONT
></TD
></TR
></TABLE
>
   in <TT
CLASS=3D"FILENAME"
>/etc/hosts.allow</TT
>.  If you are not sure what your
   network or netmask are, you can use the <B
CLASS=3D"COMMAND"
>ifconfig</B
> command to
   determine the netmask and the <B
CLASS=3D"COMMAND"
>netstat</B
> command to
   determine the network.  For, example, for the=20
   device eth0 on the above machine <B
CLASS=3D"COMMAND"
>ifconfig</B
> should show:
   </P
><P
>   <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>   ...
   eth0   Link encap:Ethernet  HWaddr 00:60:8C:96:D5:56
          inet addr:192.168.0.254  Bcast:192.168.0.255 Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:360315 errors:0 dropped:0 overruns:0
          TX packets:179274 errors:0 dropped:0 overruns:0
          Interrupt:10 Base address:0x320
   ...
   </PRE
></FONT
></TD
></TR
></TABLE
>

   and <B
CLASS=3D"COMMAND"
>netstat -rn</B
> should show:

   <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>   Kernel routing table
   Destination     Gateway         Genmask         Flags Metric Ref Use    =
Iface
   ...
   192.168.0.0     0.0.0.0         255.255.255.0   U     0      0   174412 =
eth0
   ...
   </PRE
></FONT
></TD
></TR
></TABLE
>
   (The network address is in the first column).
  </P
><P
>    The <TT
CLASS=3D"FILENAME"
>/etc/hosts.deny</TT
> and <TT
CLASS=3D"FILENAME"
>/etc/hosts.allow</TT
> files are=20
    described in the manual pages of the same names.
  </P
><P
>   <EM
>    IMPORTANT: Do not put anything but IP NUMBERS in the portmap lines of
    these files.  Host name lookups can indirectly cause portmap activity
    which will trigger host name lookups which can indirectly cause
    portmap activity which will trigger...
   </EM
>
  </P
><P
>    Versions 0.2.0 and higher of the nfs-utils package also use the=20
    <TT
CLASS=3D"FILENAME"
>hosts.allow</TT
> and <TT
CLASS=3D"FILENAME"
>hosts.deny</TT
>=20
    files, so you should put in entries for <B
CLASS=3D"COMMAND"
>lockd</B
>,=20
    <B
CLASS=3D"COMMAND"
>statd</B
>, <B
CLASS=3D"COMMAND"
>mountd</B
>, and=20
    <B
CLASS=3D"COMMAND"
>rquotad</B
> in these files too.  For a complete example,
    see <A
HREF=3D"server.html#HOSTS"
>Section 3.2.2</A
>.
  </P
><P
>    The above things should make your server tighter.  The only remaining
    problem is if someone gains administrative access to one of your truste=
d
    client machines and is able to send bogus NFS requests.  The next secti=
on
    deals with safeguards against this problem.=20
  </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SERVER.SECURITY"
>6.2. Server security: nfsd and mountd</A
></H2
><P
>    On the server we can decide that we don't want to trust any requests
    made as root on the client.  We can do that by using the=20
    <TT
CLASS=3D"USERINPUT"
><B
>root_squash</B
></TT
> option in <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
>:
   <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>   /home slave1(rw,root_squash)
   </PRE
></FONT
></TD
></TR
></TABLE
>
   </P
><P
>     This is, in fact, the default. It should always be turned on unless y=
ou
     have a <EM
>very</EM
> good reason to turn it off. To turn it off use the=20
     <TT
CLASS=3D"USERINPUT"
><B
>no_root_squash</B
></TT
> option.
   </P
><P
>     Now, if a user with <EM
>UID</EM
> 0 (i.e., root's user ID number)=20
     on the client attempts to access (read, write, delete) the file system=
,=20
     the server substitutes the <EM
>UID</EM
> of the server's 'nobody'=20
     account.  Which means that the root user on the client can't access or=
=20
     change files that only root on the server can access or change.  That'=
s=20
     good, and you should  probably use <TT
CLASS=3D"USERINPUT"
><B
>root_squash</B
></TT
> on=20
     all the file systems you export.  "But the root user on the client can=
=20
     still use <B
CLASS=3D"COMMAND"
>su</B
> to become any other user and=20
     access and change that users files!" say you.  To which the answer is:=
=20
     Yes, and that's the way it is, and has to be with Unix and NFS.  This=20
     has one important implication: All important binaries and files should=
 be
     owned by root, and not bin or other non-root account, since the only
     account the clients root user cannot access is the servers root
     account.  In the <EM
>exports(5)</EM
> man page there are several other squash=20
     options listed so that you can decide to mistrust whomever you (don't)=
=20
     like on the clients. =20
   </P
><P
>     The TCP ports 1-1024 are reserved for root's use (and therefore somet=
imes
     referred to as "secure ports") A non-root user cannot bind these ports=
.
     Adding the <TT
CLASS=3D"USERINPUT"
><B
>secure</B
></TT
> option to an=20
     <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> means that it will only listed to
     requests coming from ports 1-1024 on the client, so that a malicious
     non-root user on the client cannot come along and open up a spoofed=20
     NFS dialogue on a non-reserved port. This option is set by default.
   </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"CLIENT.SECURITY"
>6.3. Client Security</A
></H2
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"NOSUID"
>6.3.1. The nosuid mount option</A
></H3
><P
>      On the client we can decide that we don't want to trust the server t=
oo
      much a couple of ways with options to mount.  For example we can
      forbid suid programs to work off the NFS file system with the=20
      <TT
CLASS=3D"USERINPUT"
><B
>nosuid</B
></TT
>
      option. Some unix programs, such as passwd, are called "suid" program=
s:=20
      They set the id of the person running them to whomever is the owner o=
f=20
      the file. If a file is owned by root and is suid, then the program wi=
ll
      execute as root, so that they can perform operations (such as writing=
 to
      the password file) that only root is allowed to do. Using the=20
      <TT
CLASS=3D"USERINPUT"
><B
>nosuid</B
></TT
>=20
      option is a good idea and you should consider using this with all NFS=
=20
      mounted disks.  It means that the server's root user=20
      cannot make a suid-root=20
      program on the file system, log in to the client as a normal user=20
      and then use the suid-root program to become root on the client too. =
=20
      One could also forbid execution of files on the mounted file system=20
      altogether with the <TT
CLASS=3D"USERINPUT"
><B
>noexec</B
></TT
> option. =20
      But this is more likely to be impractical than=20
      <TT
CLASS=3D"USERINPUT"
><B
>nosuid</B
></TT
> since a file=20
      system is likely to at least contain some scripts or programs that ne=
ed=20
      to be executed.
    </P
></DIV
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"BROKENSUID"
>6.3.2. The broken_suid mount option</A
></H3
><P
>      Some older programs (<B
CLASS=3D"COMMAND"
>xterm</B
> being one of them) used to rely on the idea
      that root can write everywhere. This is will break under new kernels =
on
      NFS mounts.  The security implications are that programs that do this
      type of suid action can potentially be used to change your apparent u=
id
      on nfs servers doing uid mapping. So the default has been to disable =
this
     <TT
CLASS=3D"USERINPUT"
><B
>broken_suid</B
></TT
> in the linux kernel.=20
    </P
><P
>      The long and short of it is this: If you're using an old linux
      distribution, some sort of old suid program or an older unix of some
      type you <EM
>might</EM
> have to mount from your clients with the
      <TT
CLASS=3D"USERINPUT"
><B
>broken_suid</B
></TT
> option to <B
CLASS=3D"COMMAND"
>mount</B
>. =20
      However, most recent unixes and linux distros have <B
CLASS=3D"COMMAND"
>xterm</B
> and such programs=20
      just as a normal executable with no suid status, they call programs t=
o do their setuid work.
    </P
><P
>      You enter the above options in the options column, with the <TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
> and
      <TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
>, separated by commas.
    </P
></DIV
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"SECURING-DAEMONS"
>6.3.3. Securing portmapper, rpc.statd, and rpc.lockd on the client</A
></H3
><P
>     In the current (2.2.18+) implementation of NFS, full file locking is=20
     supported. This means that <B
CLASS=3D"COMMAND"
>rpc.statd</B
> and <B
CLASS=3D"COMMAND"
>rpc.lockd</B
>
     must be running on the client in order for locks to function correctly=
.=20
     These services require the portmapper to be running. So, most of the=20
     problems you will find with nfs on the server you may also be plagued =
with=20
     on the client. Read through the portmapper section above for informati=
on on=20
     securing the portmapper.
   </P
></DIV
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"FIREWALLS"
>6.4. NFS and firewalls (ipchains and netfilter)</A
></H2
><P
>    IPchains (under the 2.2.X kernels) and netfilter (under the 2.4.x=20
    kernels) allow a good level of security - instead of relying on the=20
    daemon (or  perhaps its TCP wrapper) to=20
    determine which machines can connect,=20
    the connection attempt is allowed or disallowed at a lower level. In=20
    this case, you can stop the connection much earlier and more globally, =
which
    can protect you from all sorts of attacks.
  </P
><P
>    Describing how to set up a Linux firewall is well beyond the scope of
    this document. Interested readers may wish to read the <A
HREF=3D"http://www.linuxdoc.org/HOWTO/Firewall-HOWTO.html"
TARGET=3D"_top"
>Firewall-HOWTO</A
>=20
    or the <A
HREF=3D"http://www.linuxdoc.org/HOWTO/IPCHAINS-HOWTO.HTML"
TARGET=3D"_top"
>IPCHAINS-HOWTO</A
>.
    For users of kernel 2.4 and above you might want to visit the netfilter=
 webpage at:=20
    <A
HREF=3D"http://netfilter.filewatcher.org"
TARGET=3D"_top"
>http://netfilter.filewatcher.org</A
>.
    If you are already familiar with the workings of ipchains or netfilter=20
    this section will give you a few tips on how to better setup your=20
    NFS daemons to more easily firewall and protect them.
  </P
><P
>    A good rule to follow for your firewall configuration is to deny all, =
and
    allow only some - this helps to keep you from accidentally allowing mor=
e=20
    than you intended.
  </P
><P
> In order to understand how to firewall the NFS daemons, it will help
 to breifly review how they bind to ports.</P
><P
>When a daemon starts up, it requests a free port from the portmapper.=20
The portmapper gets the port for the daemon and keeps track of=20
the port currently used by that daemon. When other hosts or processes
need to communicate with the daemon, they request the port number
from the portmapper in order to find the
daemon. So the ports will perpetually float because different ports may=20
be free at different times and so the portmapper will allocate them=20
differently each time. This is a pain for setting up a firewall. If=20
you never know where the daemons are going to be then you don't=20
know precisely which ports to allow access to. This might not be a big deal=
=20
for many people running on a protected or isolated LAN. For those=20
people on a public network, though, this is horrible.</P
><P
>In kernels 2.4.13 and later with nfs-utils 0.3.3 or later you no=20
longer have to worry about the floating of ports in the portmapper.=20
Now all of the daemons pertaining to nfs can be "pinned" to a port.=20
Most of them nicely take a <B
CLASS=3D"COMMAND"
>-p</B
> option when they are started;
those daemons that are started by the kernel take some kernel arguments=20
or module options. They are described below.</P
><P
>Some of the daemons involved in sharing data via nfs are already=20
bound to a port. <B
CLASS=3D"COMMAND"
>portmap</B
> is always on port=20
111 tcp and udp. <B
CLASS=3D"COMMAND"
>nfsd</B
> is=20
always on port 2049 TCP and UDP (however, as of kernel 2.4.17, NFS over
TCP is considered experimental and is not for use on production machines).<=
/P
><P
>The other daemons, <B
CLASS=3D"COMMAND"
>statd</B
>, <B
CLASS=3D"COMMAND"
>mountd</B
>,
<B
CLASS=3D"COMMAND"
>lockd</B
>, and <B
CLASS=3D"COMMAND"
>rquotad</B
>, will normally move
around to the first available port they are informed of by the portmapper.<=
/P
><P
>To force <B
CLASS=3D"COMMAND"
>statd</B
> to bind to a particular port, use the=20
<TT
CLASS=3D"USERINPUT"
><B
>-p</B
></TT
>
<EM
>portnum</EM
> option. To force <B
CLASS=3D"COMMAND"
>statd</B
> to=20
respond on a  particular port, additionally use the=20
<TT
CLASS=3D"USERINPUT"
><B
>-o</B
></TT
> <EM
>portnum</EM
> option when starting it.</P
><P
>To force <B
CLASS=3D"COMMAND"
>mountd</B
> to bind to a particular port use the=20
<TT
CLASS=3D"USERINPUT"
><B
>-p</B
></TT
> <EM
>portnum</EM
> option.</P
><P
>For example, to have statd broadcast of port 32765 and listen on port
32766, and mountd listen on port 32767, you would type:</P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
># statd -p 32765 -o 32766
# mountd -p 32767</PRE
></FONT
></TD
></TR
></TABLE
><P
><B
CLASS=3D"COMMAND"
>lockd</B
> is started by the kernel when it is needed.=20
Therefore you need=20
to pass module options (if you have it built as a module) or kernel=20
options to force <B
CLASS=3D"COMMAND"
>lockd</B
> to listen and respond=20
only on certain ports.</P
><P
>If you are using loadable modules and you would like to specify these
options in your <TT
CLASS=3D"FILENAME"
>/etc/modules.conf</TT
> file add=20
a line like this to the file:</P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>options lockd nlm.uddpport=3D32768 nlm.tcpport=3D32768</PRE
></FONT
></TD
></TR
></TABLE
><P
>The above line would specify the udp and tcp port for=20
<B
CLASS=3D"COMMAND"
>lockd</B
> to be 32768.</P
><P
>If you are not using loadable modules or if you have compiled=20
<B
CLASS=3D"COMMAND"
>lockd</B
> into the kernel instead of building it
 as a module then you will need to pass it an option on the kernel boot lin=
e.</P
><P
>It should look something like this:</P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
> vmlinuz 3 root=3D/dev/hda1 lockd.udpport=3D32768 lockd.tcpport=3D32768</P=
RE
></FONT
></TD
></TR
></TABLE
><P
>The port numbers do not have to match but it would simply add=20
unnecessary confusion if they didn't.</P
><P
>If you are using quotas and using <B
CLASS=3D"COMMAND"
>rpc.quotad</B
> to make these=20
quotas viewable over nfs you will need to also take it into
account when setting up your firewall. There are two=20
<B
CLASS=3D"COMMAND"
>rpc.rquotad</B
>=20
source trees. One of those is maintained in the=20
<SPAN
CLASS=3D"APPLICATION"
>nfs-utils</SPAN
> tree.=20
The other in the <SPAN
CLASS=3D"APPLICATION"
>quota-tools</SPAN
> tree.=20
They do not operate identically.=20
The one provided with <SPAN
CLASS=3D"APPLICATION"
>nfs-utils</SPAN
> supports=20
binding the daemon to  a port with the <TT
CLASS=3D"USERINPUT"
><B
>-p</B
></TT
>=20
directive. The one in <SPAN
CLASS=3D"APPLICATION"
>quota-tools</SPAN
> does not.=20
Consult your distribution's documentation to determine if yours does. </P
><P
>For the sake of this discussion lets describe a network and setup a=20
firewall to protect our nfs server.=20
Our nfs server is 192.168.0.42 our client is 192.168.0.45 only.
As in the example above, <B
CLASS=3D"COMMAND"
>statd</B
> has been=20
started so that it only
binds to port 32765 for incoming requests and it must answer on=20
port 32766.  <B
CLASS=3D"COMMAND"
>mountd</B
> is forced to bind to port 32767.
<B
CLASS=3D"COMMAND"
>lockd</B
>'s module parameters have been set to bind to 32768.
<B
CLASS=3D"COMMAND"
>nfsd</B
> is, of course, on port 2049 and the portmapper is on port 111.</P
><P
>We are not using quotas.</P
><P
>Using <SPAN
CLASS=3D"APPLICATION"
>IPCHAINS</SPAN
>, a simple firewall=20
might look something like this:</P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>ipchains -A input -f -j ACCEPT -s 192.168.0.45
ipchains -A input -s 192.168.0.45 -d 0/0 32765:32768 -p 6 -j ACCEPT
ipchains -A input -s 192.168.0.45 -d 0/0 32765:32768 -p 17 -j ACCEPT
ipchains -A input -s 192.168.0.45 -d 0/0 2049 -p 17 -j ACCEPT
ipchains -A input -s 192.168.0.45 -d 0/0 2049 -p 6 -j ACCEPT
ipchains -A input -s 192.168.0.45 -d 0/0 111 -p 6 -j ACCEPT
ipchains -A input -s 192.168.0.45 -d 0/0 111 -p 17 -j ACCEPT
ipchains -A input -s 0/0 -d 0/0 -p 6 -j DENY -y -l
ipchains -A input -s 0/0 -d 0/0 -p 17 -j DENY -l</PRE
></FONT
></TD
></TR
></TABLE
><P
>The equivalent set of commands in <SPAN
CLASS=3D"APPLICATION"
>netfilter</SPAN
> is:</P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>iptables -A INPUT -f -j ACCEPT -s 192.168.0.45
iptables -A INPUT -s 192.168.0.45 -d 0/0 32765:32768 -p 6 -j ACCEPT
iptables -A INPUT -s 192.168.0.45 -d 0/0 32765:32768 -p 17 -j ACCEPT
iptables -A INPUT -s 192.168.0.45 -d 0/0 2049 -p 17 -j ACCEPT
iptables -A INPUT -s 192.168.0.45 -d 0/0 2049 -p 6 -j ACCEPT
iptables -A INPUT -s 192.168.0.45 -d 0/0 111 -p 6 -j ACCEPT
iptables -A INPUT -s 192.168.0.45 -d 0/0 111 -p 17 -j ACCEPT
iptables -A INPUT -s 0/0 -d 0/0 -p 6 -j DENY --syn --log-level 5
iptables -A INPUT -s 0/0 -d 0/0 -p 17 -j DENY --log-level 5</PRE
></FONT
></TD
></TR
></TABLE
><P
>The first line says to accept all packet fragments (except the=20
first packet fragment which will be treated as a normal packet).=20
In theory no packet will pass through until it is reassembled,=20
and it won't be reassembled unless the first packet fragment=20
is passed. Of course there are attacks that can be generated=20
by overloading a machine with packet fragments. But NFS won't=20
work correctly unless you let fragments through. See <A
HREF=3D"troubleshooting.html#SYMPTOM8"
>Section 7.8</A
>
for details.</P
><P
>The other lines allow specific connections from any port on our=20
client host to the specific ports we have made available on=20
our server.  This means that if, say, 192.158.0.46 attempts to contact=20
the NFS server it will not be able to mount or see what mounts=20
are available.</P
><P
>With the new port pinning capabilities it is obviously much easier
to control what hosts are allowed to mount your NFS shares. It is
worth mentioning that NFS is not an encrypted protocol and anyone
on the same physical network could sniff the traffic and reassemble
the information being passed back and forth.
 </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"NFS-SSH"
>6.5. Tunneling NFS through SSH</A
></H2
><P
>One method of encrypting NFS traffic over a network is to=20
use the port-forwarding capabilities of <B
CLASS=3D"COMMAND"
>ssh</B
>.
However, as we shall see, doing so has a serious drawback if you do not
utterly and completely trust the local users on your server.</P
><P
>The first step will be to export files to the localhost.  For example, to
export the <TT
CLASS=3D"FILENAME"
>/home</TT
> partition, enter the following into=20
<TT
CLASS=3D"FILENAME"
>/etc/exports</TT
>:
<TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>/home   127.0.0.1(rw)</PRE
></FONT
></TD
></TR
></TABLE
></P
><P
>The next step is to use <B
CLASS=3D"COMMAND"
>ssh</B
> to forward ports.  For example,
<B
CLASS=3D"COMMAND"
>ssh</B
> can tell the server to forward to any port on any
machine from a port on the client.  Let us assume, as in the previous
section, that our server is 192.168.0.42, and that we have pinned=20
<B
CLASS=3D"COMMAND"
>mountd</B
> to port 32767
using the argument <TT
CLASS=3D"USERINPUT"
><B
>-p 32767</B
></TT
>. Then, on the client,
we'll type:
<TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>     # ssh root@192.168.0.42 -L 250:localhost:2049  -f sleep 60m
     # ssh root@192.168.0.42 -L 251:localhost:32767 -f sleep 60m</PRE
></FONT
></TD
></TR
></TABLE
></P
><P
>The above command causes <B
CLASS=3D"COMMAND"
>ssh</B
> on the client to take
any request directed at the client's port 250 and forward it,=20
first through <B
CLASS=3D"COMMAND"
>sshd</B
> on the server, and then on
 to the server's port 2049.  The second line
causes a similar type of forwarding between requests to port 251 on
the client and port 32767 on the server.  The=20
<TT
CLASS=3D"USERINPUT"
><B
>localhost</B
></TT
> is relative to the server; that is,
the forwarding will be done to the server itself.  The port could otherwise
have been made to forward to any other machine, and the requests would look=
 to
the outside world as if they were coming from the server.  Thus, the reques=
ts
will appear to NFSD on the server as if they are coming from the server its=
elf.=20
Note that in order to bind to a port below 1024 on the client, we have=20
to run this command as root on the client.  Doing this will be necessary=20
if we have exported our filesystem with the default=20
<TT
CLASS=3D"USERINPUT"
><B
>secure</B
></TT
> option.</P
><P
>Finally, we are pulling a little trick with the last option,
<TT
CLASS=3D"USERINPUT"
><B
>-f sleep 60m</B
></TT
>.  Normally, when
we use <B
CLASS=3D"COMMAND"
>ssh</B
>, even with the <TT
CLASS=3D"USERINPUT"
><B
>-L</B
></TT
> option,
we will open up a shell on the remote machine.  But instead, we just want
the port forwarding to execute in the background so that we get our shell
on the client back.  So, we tell <B
CLASS=3D"COMMAND"
>ssh</B
> to execute a command
in the background on the server to sleep for 60 minutes.  This will cause
the port to be forwarded for 60 minutes until it gets a connection; at that
point, the port will continue to be forwarded until the connection dies or
until the 60 minutes are up, whichever happens later.  The above command
could be put in our startup scripts on the client, right after the network
is started.</P
><P
>  Next, we have to mount the filesystem on the client.  To do this, we tel=
l
  the client to mount a filesystem on the localhost, but at a different
  port from the usual 2049.  Specifically, an entry in <TT
CLASS=3D"FILENAME"
>/etc/fstab</TT
>
  would look like:
<TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>  localhost:/home  /mnt/home  nfs  rw,hard,intr,port=3D250,mountport=3D251=
  0 0</PRE
></FONT
></TD
></TR
></TABLE
></P
><P
>Having done this, we can see why the above will be incredibly insecure
if we have <EM
>any</EM
> ordinary users who are able to log in
to the server locally.  If they can, there is nothing preventing them from
doing what we did and using <B
CLASS=3D"COMMAND"
>ssh</B
> to forward a privileged=20
port on their own client machine (where they are legitimately root) to port=
s
2049 and 32767 on the server.  Thus, any ordinary user on the server can
mount our filesystems with the same rights as root on our client.</P
><P
>If you are using an NFS server that does not have a way for ordinary users
to log in, and you wish to use this method, there are two additional caveat=
s:
First, the connection travels from the client to the server via
<B
CLASS=3D"COMMAND"
>sshd</B
>; therefore you will have to leave port 22 (where
<B
CLASS=3D"COMMAND"
>sshd</B
> listens) open to your client on the firewall.  However
you do not need to leave the other ports, such as 2049 and 32767, open
anymore.  Second, file locking will no longer work.  It is not possible
to ask <B
CLASS=3D"COMMAND"
>statd</B
> or the locking manager to make requests
to a particular port for a particular mount; therefore, any locking request=
s
will cause <B
CLASS=3D"COMMAND"
>statd</B
> to connect to <B
CLASS=3D"COMMAND"
>statd</B
>
on localhost, i.e., itself, and it will fail with an error.  Any attempt
to correct this would require a major rewrite of NFS.</P
><P
>It may also be possible to use <SPAN
CLASS=3D"APPLICATION"
>IPSec</SPAN
> to encrypt
network traffic between your client and your server, without compromising
any local security on the server; this will not be taken up here.
See the <A
HREF=3D"http://www.freeswan.org/"
TARGET=3D"_top"
>FreeS/WAN</A
> home page
for details on using IPSec under Linux.</P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SUMMARY"
>6.6. Summary</A
></H2
><P
>    If you use the <TT
CLASS=3D"FILENAME"
>hosts.allow</TT
>, <TT
CLASS=3D"FILENAME"
>hosts.deny</TT
>,
   <TT
CLASS=3D"USERINPUT"
><B
>root_squash</B
></TT
>, <TT
CLASS=3D"USERINPUT"
><B
>nosuid</B
></TT
> and privileged
    port features in the portmapper/NFS software, you avoid many of the
    presently known bugs in NFS and can almost feel secure about that at
    least.  But still, after all that: When an intruder has access to your
    network, s/he can make strange commands appear in your <TT
CLASS=3D"FILENAME"
>.forward</TT
> or
    read your mail when <TT
CLASS=3D"FILENAME"
>/home</TT
> or <TT
CLASS=3D"FILENAME"
>/var/mail</TT
> is=20
    NFS exported.  For the same reason, you should never access your PGP pr=
ivate key=20
    over NFS. Or at least you should know the risk involved.  And now you k=
now a bit
    of it.
  </P
><P
>    NFS and the portmapper makes up a complex subsystem and therefore it's
    not totally unlikely that new bugs will be discovered, either in the
    basic design or the implementation we use.  There might even be holes
    known now, which someone is abusing.  But that's life. =20
  </P
></DIV
></DIV
><DIV
CLASS=3D"NAVFOOTER"
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
><A
HREF=3D"performance.html"
>Prev</A
></TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
><A
HREF=3D"index.html"
>Home</A
></TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
><A
HREF=3D"troubleshooting.html"
>Next</A
></TD
></TR
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
>Optimizing NFS Performance</TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
>&nbsp;</TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
>Troubleshooting</TD
></TR
></TABLE
></DIV
></BODY
></HTML
>
--=-DzUZBAgzdIo18XiQgRt5
Content-Disposition: attachment; filename=troubleshooting.html
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html; charset=ISO-8859-1

<HTML
><HEAD
><TITLE
>Troubleshooting</TITLE
><META
NAME=3D"GENERATOR"
CONTENT=3D"Modular DocBook HTML Stylesheet Version 1.64
"><LINK
REL=3D"HOME"
TITLE=3D"Linux NFS-HOWTO"
HREF=3D"index.html"><LINK
REL=3D"PREVIOUS"
TITLE=3D"Security and NFS"
HREF=3D"security.html"><LINK
REL=3D"NEXT"
TITLE=3D"Using Linux NFS with Other OSes"
HREF=3D"interop.html"></HEAD
><BODY
CLASS=3D"SECT1"
BGCOLOR=3D"#FFFFFF"
TEXT=3D"#000000"
LINK=3D"#0000FF"
VLINK=3D"#840084"
ALINK=3D"#0000FF"
><DIV
CLASS=3D"NAVHEADER"
><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TH
COLSPAN=3D"3"
ALIGN=3D"center"
>Linux NFS-HOWTO</TH
></TR
><TR
><TD
WIDTH=3D"10%"
ALIGN=3D"left"
VALIGN=3D"bottom"
><A
HREF=3D"security.html"
>Prev</A
></TD
><TD
WIDTH=3D"80%"
ALIGN=3D"center"
VALIGN=3D"bottom"
></TD
><TD
WIDTH=3D"10%"
ALIGN=3D"right"
VALIGN=3D"bottom"
><A
HREF=3D"interop.html"
>Next</A
></TD
></TR
></TABLE
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"></DIV
><DIV
CLASS=3D"SECT1"
><H1
CLASS=3D"SECT1"
><A
NAME=3D"TROUBLESHOOTING"
>7. Troubleshooting</A
></H1
><BLOCKQUOTE
CLASS=3D"ABSTRACT"
><DIV
CLASS=3D"ABSTRACT"
><A
NAME=3D"AEN935"
></A
><P
></P
><P
>   This is intended as a step-by-step guide to what to do when
   things go wrong using NFS.  Usually trouble first rears its
   head on the client end, so this diagnostic will begin there.
 </P
><P
></P
></DIV
></BLOCKQUOTE
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SYMPTOM1"
>7.1. Unable to See Files on a Mounted File System</A
></H2
><P
>       First, check to see if the file system is actually mounted.
       There are several ways of doing this.  The most reliable
       way is to look at the file <TT
CLASS=3D"FILENAME"
>/proc/mounts</TT
>,=20
       which will list all mounted filesystems and give details about them.=
  If
       this doesn't work (for example if you don't have the /proc
       filesystem compiled into your kernel), you can type=20
       <TT
CLASS=3D"USERINPUT"
><B
>mount -f</B
></TT
> although you get less information. =20
     </P
><P
>       If the file system appears to be mounted, then you may
       have mounted another file system on top of it (in which
       case you should unmount and remount both volumes), or you=20
       may have exported the file system on the server before you=20
       mounted it there, in which case NFS is exporting the underlying=20
       mount point (if so then you need to restart NFS on the=20
       server).
     </P
><P
>       If the file system is not mounted, then attempt to mount it.
       If this does not work, see <A
HREF=3D"troubleshooting.html#SYMPTOM3"
><I
>Symptom 3</I
></A
>.
     </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SYMPTOM2"
>7.2. File requests hang or timeout waiting for access to the file.</A
></H2
><P
>      This usually means that the client is unable to communicate with
      the server.  See <A
HREF=3D"troubleshooting.html#SYMPTOM3"
><I
>Symptom 3</I
></A
> letter b.
     </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SYMPTOM3"
>7.3. Unable to mount a file system</A
></H2
><P
>       There are two common errors that mount produces when
       it is unable to mount a volume.  These are:
      <P
></P
><OL
TYPE=3D"a"
><LI
><P
>          failed, reason given by server:=20
          <TT
CLASS=3D"COMPUTEROUTPUT"
>Permission denied</TT
>
        </P
><P
>  =20
          This means that the server does not recognize that you
          have access to the volume. =20
        </P
><P
></P
><OL
TYPE=3D"i"
><LI
><P
>              Check your <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> file and make sure that the
              volume is exported and that your client has the right
              kind of access to it.  For example, if a client only
              has read access then you have to mount the volume
              with the <TT
CLASS=3D"USERINPUT"
><B
>ro</B
></TT
> option rather=20
              than the <TT
CLASS=3D"USERINPUT"
><B
>rw</B
></TT
> option.
            </P
></LI
><LI
><P
>             Make sure that you have told NFS to register any
             changes you made to <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> since starting nfsd
             by running the exportfs command.  Be sure to type
             <B
CLASS=3D"COMMAND"
>exportfs -ra</B
> to be extra certain that the exports are
             being re-read.
           </P
></LI
><LI
><P
>             Check the file <TT
CLASS=3D"FILENAME"
>/proc/fs/nfs/exports</TT
> and make sure the=20
             volume and client are listed correctly.  (You can also
             look at the file <TT
CLASS=3D"FILENAME"
>/var/lib/nfs/xtab</TT
> for an unabridged
             list of how all the active export options are set.)  If they=20
             are not, then you have not re-exported properly.  If they
             are listed, make sure the server recognizes your
             client as being the machine you think it is.  For
             example, you may have an old listing for the client
             in <TT
CLASS=3D"FILENAME"
>/etc/hosts</TT
> that is throwing off the server, or
             you may not have listed the client's complete address
             and it may be resolving to a machine in a different=20
             domain.  One trick is login to the server from the
             client via <B
CLASS=3D"COMMAND"
>ssh</B
> or <B
CLASS=3D"COMMAND"
>telnet</B
>;
             if you then type <B
CLASS=3D"COMMAND"
>who</B
>, one of the listings
             should be your login session and the name of your client
             machine as the server sees it.  Try using this machine name
             in your <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> entry.
             Finally, try to ping the client from the server, and try
             to <B
CLASS=3D"COMMAND"
>ping</B
> the server from the client.  If this doesn't work,
             or if there is packet loss, you may have lower-level network=20
             problems.
           </P
></LI
><LI
><P
>             It is not possible to export both a directory and its child
             (for example both=20
             <TT
CLASS=3D"FILENAME"
>/usr</TT
> and <TT
CLASS=3D"FILENAME"
>/usr/local</TT
>).
             You should export the parent directory with the necessary
             permissions, and all of its subdirectories can then be
             mounted with those same permissions.
           </P
></LI
></OL
></LI
><LI
><P
><TT
CLASS=3D"COMPUTEROUTPUT"
>          RPC: Program Not Registered</TT
>: (or another "RPC" error):</P
><P
>          This means that the client does not detect NFS running
          on the server.  This could be for several reasons.
        </P
><P
></P
><OL
TYPE=3D"i"
><LI
><P
>            First, check that NFS actually is running on the
            server by typing <B
CLASS=3D"COMMAND"
>rpcinfo -p</B
> on the server.
            You should see something like this:
         <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"90%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100011    1   udp    749  rquotad
    100011    2   udp    749  rquotad
    100005    1   udp    759  mountd
    100005    1   tcp    761  mountd
    100005    2   udp    764  mountd
    100005    2   tcp    766  mountd
    100005    3   udp    769  mountd
    100005    3   tcp    771  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    300019    1   tcp    830  amd
    300019    1   udp    831  amd
    100024    1   udp    944  status
    100024    1   tcp    946  status
    100021    1   udp   1042  nlockmgr
    100021    3   udp   1042  nlockmgr
    100021    4   udp   1042  nlockmgr
    100021    1   tcp   1629  nlockmgr
    100021    3   tcp   1629  nlockmgr
    100021    4   tcp   1629  nlockmgr
  </PRE
></FONT
></TD
></TR
></TABLE
>

            This says that we have NFS versions 2 and 3, rpc.statd=20
            version 1, network lock manager (the service name for=20
            <B
CLASS=3D"COMMAND"
>rpc.lockd</B
>) versions 1, 3, and 4.
            There are also different
            service listings depending on whether NFS is travelling over=20
            TCP or UDP.  UDP is usually (but not always) the default=20
            unless TCP is explicitly requested.
          </P
><P
>            If you do not see at least <TT
CLASS=3D"COMPUTEROUTPUT"
>portmapper</TT
>,            <TT
CLASS=3D"COMPUTEROUTPUT"
>nfs</TT
>, and
            <TT
CLASS=3D"COMPUTEROUTPUT"
>mountd</TT
>, then=20
            you need to restart NFS.  If you are not able to restart=20
            successfully, proceed to <A
HREF=3D"troubleshooting.html#SYMPTOM9"
><I
>Symptom 9</I
></A
>.
          </P
></LI
><LI
><P
>            Now check to make sure you can see it from the client.
            On the client, type <B
CLASS=3D"COMMAND"
>rpcinfo -p </B
>=20
            <EM
>server</EM
> where <EM
>server</EM
>
            is the DNS name or IP address of your server. =20
          </P
><P
>            If you get a listing, then make sure that the type
            of mount you are trying to perform is supported. For
            example, if you are trying to mount using Version 3
            NFS, make sure Version 3 is listed; if you are trying
            to mount using NFS over TCP, make sure that is
            registered.  (Some non-Linux clients default to TCP).
            Type <TT
CLASS=3D"USERINPUT"
><B
>man rpcinfo</B
></TT
> for more details on how
            to read the output.  If the type of mount you are
            trying to perform is not listed, try a different
            type of mount.
          </P
><P
>            If you get the error=20
            <TT
CLASS=3D"COMPUTEROUTPUT"
>No Remote Programs Registered</TT
>,
            then you need to check your <TT
CLASS=3D"FILENAME"
>/etc/hosts.allow</TT
> and
            <TT
CLASS=3D"FILENAME"
>/etc/hosts.deny</TT
> files on the server and make sure
            your client actually is allowed access.  Again, if the
            entries appear correct, check <TT
CLASS=3D"FILENAME"
>/etc/hosts</TT
> (or your
            DNS server) and make sure that the machine is listed
            correctly, and make sure you can ping the server from
            the client.  Also check the error logs on the system
            for helpful messages: Authentication errors from bad
            <TT
CLASS=3D"FILENAME"
>/etc/hosts.allow</TT
> entries will usually appear in=20
            <TT
CLASS=3D"FILENAME"
>/var/log/messages</TT
>,=20
            but may appear somewhere else depending
            on how your system logs are set up.  The man pages
            for <TT
CLASS=3D"COMPUTEROUTPUT"
>syslog</TT
> can=20
            help you figure out how your logs are
            set up.  Finally, some older operating systems may
            behave badly when routes between the two machines
            are asymmetric.  Try typing <B
CLASS=3D"COMMAND"
>tracepath [server]</B
> from
            the client and see if the word "asymmetric" shows up
            anywhere in the output.  If it does then this may
            be causing packet loss.  However asymmetric routes are
            not usually a problem on recent linux distributions.
          </P
><P
>            If you get the error=20
            <TT
CLASS=3D"COMPUTEROUTPUT"
>Remote system error - No route to host</TT
>,
            but you can ping the server correctly,
            then you are the victim of an overzealous
            firewall.  Check any firewalls that may be set up,
            either on the server or on any routers in between
            the client and the server.  Look at the man pages
            for <B
CLASS=3D"COMMAND"
>ipchains</B
>, <B
CLASS=3D"COMMAND"
>netfilter</B
>,=20
            and <B
CLASS=3D"COMMAND"
>ipfwadm</B
>, as well as the=20
            <A
HREF=3D"http://www.linuxdoc.org/HOWTO/IPCHAINS-HOWTO.html"
TARGET=3D"_top"
>IPChains-HOWTO</A
>
            and the <A
HREF=3D"http://www.linuxdoc.org/HOWTO/Firewall-HOWTO.html"
TARGET=3D"_top"
>Firewall-HOWTO</A
> for help.
          </P
></LI
></OL
></LI
></OL
>
    </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SYMPTOM4"
>7.4. I do not have permission to access files on the mounted volume.</A
></H2
><P
>     This could be one of two problems. =20
   </P
><P
>     If it is a write permission problem, check the export=20
     options on the server by looking at <TT
CLASS=3D"FILENAME"
>/proc/fs/nfs/exports</TT
>
     and make sure the filesystem is not exported read-only. =20
     If it is you will need to re-export it read/write=20
     (don't forget to run <B
CLASS=3D"COMMAND"
>exportfs -ra</B
> after editing
     <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
>).  Also, check
     <TT
CLASS=3D"FILENAME"
>/proc/mounts</TT
> and make sure the volume=20
     is mounted read/write (although if it is mounted read-only=20
     you ought to get a more specific error message).  If not then=20
     you need to re-mount with the <TT
CLASS=3D"USERINPUT"
><B
>rw</B
></TT
> option.
   </P
><P
>     The second problem has to do with username mappings, and is
     different depending on whether you are trying to do this
     as root or as a non-root user.
   </P
><P
>     If you are not root, then usernames may not be in sync on=20
     the client and the server. Type <B
CLASS=3D"COMMAND"
>id [user]</B
>
     on both the client and the server and make sure they give the=20
     same <EM
>UID</EM
> number. If they don't then=20
     you are having problems with NIS, NIS+, rsync, or whatever=20
     system you use to sync usernames.  Check group names to make=20
     sure that they match as well. Also, make sure you are not=20
     exporting with the <TT
CLASS=3D"USERINPUT"
><B
>all_squash</B
></TT
> option. =20
     If the user names match then the user has a more general
     permissions problem unrelated to NFS.
   </P
><P
>     If you are root, then you are probably not exporting with
     the <TT
CLASS=3D"USERINPUT"
><B
>no_root_squash</B
></TT
> option; check <TT
CLASS=3D"FILENAME"
>/proc/fs/nfs/exports</TT
>
     or <TT
CLASS=3D"FILENAME"
>/var/lib/nfs/xtab</TT
> on the server and make sure the option=20
     is listed.  In general, being able to write to the NFS
     server as root is a bad idea unless you have an urgent need --
     which is why Linux NFS prevents it by default.  See
     <A
HREF=3D"security.html"
>Section 6</A
> for details. =20
   </P
><P
>     If you have root squashing, you want to keep it, and you're only=20
     trying to get root to have the same permissions on the file that
     the user <EM
>nobody</EM
> should have, then remember that it is the server
     that determines which uid root gets mapped to.  By default, the
     server uses the <EM
>UID</EM
> and <EM
>GID</EM
> of=20
     <EM
>nobody</EM
> in the <TT
CLASS=3D"FILENAME"
>/etc/passwd</TT
> file,
     but this can also be overridden with the <TT
CLASS=3D"USERINPUT"
><B
>anonuid</B
></TT
> and=20
     <TT
CLASS=3D"USERINPUT"
><B
>anongid</B
></TT
> options in the <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
>=20
     file.  Make sure that the client and the server agree about which=20
     <EM
>UID</EM
> <EM
>nobody</EM
> gets mapped to.
   </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SYMPTOM5"
>7.5. When I transfer really big files, NFS takes over
   all the CPU cycles on the server and it screeches to a halt.</A
></H2
><P
>   This is a problem with the <TT
CLASS=3D"FUNCTION"
>fsync()</TT
> function in 2.2 kernels that
   causes all sync-to-disk requests to be cumulative, resulting
   in a write time that is quadratic in the file size.  If you
   can, upgrading to a 2.4 kernel should solve the problem.
   Also, exporting with the <TT
CLASS=3D"USERINPUT"
><B
>no_wdelay</B
></TT
> option=20
   forces the program to use <TT
CLASS=3D"FUNCTION"
>o_sync()</TT
> instead, which may prove faster.
  </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SYMPTOM6"
>7.6. Strange error or log messages</A
></H2
><P
>  <P
></P
><OL
TYPE=3D"a"
><LI
><P
>  Messages of the following format:
  </P
><P
>  <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"90%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
> Jan 7 09:15:29 server kernel: fh_verify: mail/guest permission failure, a=
cc=3D4, error=3D13
 Jan 7 09:23:51 server kernel: fh_verify: ekonomi/test permission failure, =
acc=3D4, error=3D13
  </PRE
></FONT
></TD
></TR
></TABLE
>
  </P
><P
>   These happen when a NFS <TT
CLASS=3D"COMPUTEROUTPUT"
>setattr</TT
>
   operation is attempted on a=20
   file you don't have write access to. The messages are=20
   harmless.
  </P
></LI
><LI
><P
> The following messages frequently appear in the logs:
 </P
><P
> <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"90%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
> kernel: nfs: server server.domain.name not responding, still trying
 kernel: nfs: task 10754 can't get a request slot
 kernel: nfs: server server.domain.name OK
 </PRE
></FONT
></TD
></TR
></TABLE
>
 </P
><P
>   The "can't get a request slot" message means that the client-side
   RPC code has detected a lot of timeouts (perhaps due to=20
   network congestion, perhaps due to an overloaded server), and
   is throttling back the number of concurrent outstanding=20
   requests in an attempt to lighten the load.  The cause of
   these messages is basically sluggish performance.  See
   <A
HREF=3D"performance.html"
>Section 5</A
> for details.
 </P
></LI
><LI
><P
> After mounting, the following message appears on the client:
  </P
><P
>  <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"90%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>nfs warning: mount version older than kernel
  </PRE
></FONT
></TD
></TR
></TABLE
>
  </P
><P
>    It means what it says: You should upgrade your mount package and/or=20
    am-utils. (If for some reason upgrading is a problem, you may be able
    to get away with just recompiling them so that the newer kernel feature=
s
    are recognized at compile time).
  </P
></LI
><LI
><P
>    Errors in startup/shutdown log for <B
CLASS=3D"COMMAND"
>lockd</B
>
  </P
><P
>  You may see a message of the following kind in your boot log:
 <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"90%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>nfslock: rpc.lockd startup failed
 </PRE
></FONT
></TD
></TR
></TABLE
>
 </P
><P
>   They are harmless.  Older versions of <B
CLASS=3D"COMMAND"
>rpc.lockd</B
> needed to be
    started up manually, but newer versions are started automatically
    by <B
CLASS=3D"COMMAND"
>nfsd</B
>.  Many of the=20
    default startup scripts still try to start
    up <B
CLASS=3D"COMMAND"
>lockd</B
> by hand, in case=20
    it is necessary.  You can alter your
    startup scripts if you want the messages to go away.
 </P
></LI
><LI
><P
>   The following message appears in the logs:
   </P
><P
>   <TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"90%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>kmem_create: forcing size word alignment - nfs_fh
   </PRE
></FONT
></TD
></TR
></TABLE
>
   </P
><P
>     This results from the file handle being 16 bits instead of a
     mulitple of 32 bits, which makes the kernel grimace.  It is=20
     harmless.
   </P
></LI
></OL
>
 </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SYMPTOM7"
>7.7. Real permissions don't match what's in <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
>.</A
></H2
><P
>  <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> is <EM
>very</EM
> sensitive to whitespace - so the=20
  following statements are not the same:
 <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>/export/dir hostname(rw,no_root_squash)=20
/export/dir hostname (rw,no_root_squash)=20
 </PRE
></FONT
></TD
></TR
></TABLE
>
  The first will grant <TT
CLASS=3D"USERINPUT"
><B
>hostname rw</B
></TT
>
  access to <TT
CLASS=3D"FILENAME"
>/export/dir</TT
>
  without squashing root privileges. The second will grant=20
  <TT
CLASS=3D"USERINPUT"
><B
>hostname rw</B
></TT
> privileges with=20
  <TT
CLASS=3D"USERINPUT"
><B
>root squash</B
></TT
> and it will grant=20
  <EM
>everyone</EM
> else read/write access, without=20
  squashing root privileges. Nice huh?=20
 </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SYMPTOM8"
>7.8. Flaky and unreliable behavior</A
></H2
><P
>    Simple commands such as <B
CLASS=3D"COMMAND"
>ls</B
> work, but anything that transfers
    a large amount of information causes the mount point to lock.
  </P
><P
>    This could be one of two problems:
  </P
><P
></P
><OL
TYPE=3D"i"
><LI
><P
> =20
      It will happen if you have ipchains on at the server and/or the=20
      client and you are not allowing fragmented packets through the
      chains.  Allow fragments from the remote host and you'll be able=20
      to function again. See <A
HREF=3D"security.html#FIREWALLS"
>Section 6.4</A
> for details on how to do this.
    </P
></LI
><LI
><P
>      You may be using a larger <TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
>=20
      and <TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
> in your mount options
      than the server supports.  Try reducing <TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
>
      and <TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
> to 1024 and=20
      seeing if the problem goes away.  If it does, then increase them=20
      slowly to a more reasonable value.
    </P
></LI
></OL
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SYMPTOM9"
>7.9. nfsd won't start</A
></H2
><P
>     Check the file <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> and make sure root has read permission.
     Check the binaries and make sure they are executable.  Make sure
     your kernel was compiled with NFS server support.  You may need
     to reinstall your binaries if none of these ideas helps.
   </P
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SYMPTOM10"
>7.10. File Corruption When Using Multiple Clients</A
></H2
><P
>     If a file has been modified within one second of its=20
     previous modification and left the same size, it will=20
     continue to generate the same inode number.  Because
     of this, constant reads and writes to a file by
     multiple clients may cause file corruption.  Fixing
     this bug requires changes deep within the filesystem
     layer, and therefore it is a 2.5 item.
   </P
></DIV
></DIV
><DIV
CLASS=3D"NAVFOOTER"
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
><A
HREF=3D"security.html"
>Prev</A
></TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
><A
HREF=3D"index.html"
>Home</A
></TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
><A
HREF=3D"interop.html"
>Next</A
></TD
></TR
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
>Security and NFS</TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
>&nbsp;</TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
>Using Linux NFS with Other OSes</TD
></TR
></TABLE
></DIV
></BODY
></HTML
>
--=-DzUZBAgzdIo18XiQgRt5
Content-Disposition: attachment; filename=interop.html
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html; charset=ISO-8859-1

<HTML
><HEAD
><TITLE
>Using Linux NFS with Other OSes</TITLE
><META
NAME=3D"GENERATOR"
CONTENT=3D"Modular DocBook HTML Stylesheet Version 1.64
"><LINK
REL=3D"HOME"
TITLE=3D"Linux NFS-HOWTO"
HREF=3D"index.html"><LINK
REL=3D"PREVIOUS"
TITLE=3D"Troubleshooting"
HREF=3D"troubleshooting.html"></HEAD
><BODY
CLASS=3D"SECT1"
BGCOLOR=3D"#FFFFFF"
TEXT=3D"#000000"
LINK=3D"#0000FF"
VLINK=3D"#840084"
ALINK=3D"#0000FF"
><DIV
CLASS=3D"NAVHEADER"
><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TH
COLSPAN=3D"3"
ALIGN=3D"center"
>Linux NFS-HOWTO</TH
></TR
><TR
><TD
WIDTH=3D"10%"
ALIGN=3D"left"
VALIGN=3D"bottom"
><A
HREF=3D"troubleshooting.html"
>Prev</A
></TD
><TD
WIDTH=3D"80%"
ALIGN=3D"center"
VALIGN=3D"bottom"
></TD
><TD
WIDTH=3D"10%"
ALIGN=3D"right"
VALIGN=3D"bottom"
>&nbsp;</TD
></TR
></TABLE
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"></DIV
><DIV
CLASS=3D"SECT1"
><H1
CLASS=3D"SECT1"
><A
NAME=3D"INTEROP"
>8. Using Linux NFS with Other OSes</A
></H1
><P
>   Every operating system, Linux included, has quirks and deviations
   in the behavior of its NFS implementation -- sometimes because
   the protocols are vague, sometimes because they leave gaping
   security holes.  Linux will work properly with all major vendors'
   NFS implementations, as far as we know.  However, there may be
   extra steps involved to make sure the two OSes are communicating
   clearly with one another.  This section details those steps.
 </P
><P
>   In general, it is highly ill-advised to attempt to use a Linux
   machine with a kernel before 2.2.18 as an NFS server for non-Linux
   clients.  Implementations with older kernels may work fine as=20
   clients; however if you are using one of these kernels and get
   stuck, the first piece of advice we would give is to upgrade
   your kernel and see if the problems go away.  The user-space NFS
   implementations also do not work well with non-Linux clients.
 </P
><P
>   Following is a list of known issues for using Linux together with
   major operating systems.
 </P
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"AIX"
>8.1. AIX</A
></H2
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"AIXSERVER"
>8.1.1. Linux Clients and AIX Servers</A
></H3
><P
>      The format for the <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> file for our example in <A
HREF=3D"server.html"
>Section 3</A
> is:
    <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>  /usr   slave1.foo.com:slave2.foo.com,access=3Dslave1.foo.com:slave2.foo.=
com
  /home  slave1.foo.com:slave2.foo.com,rw=3Dslave1.foo.com:slave2.foo.com
    </PRE
></FONT
></TD
></TR
></TABLE
>
  </P
></DIV
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"AIXCLIENTS"
>8.1.2. AIX clients and Linux Servers</A
></H3
><P
>     AIX uses the file <TT
CLASS=3D"FILENAME"
>/etc/filesystems</TT
> instead of <TT
CLASS=3D"FILENAME"
>/etc/fstab</TT
>.
     A sample entry, based on the example in <A
HREF=3D"client.html"
>Section 4</A
>, looks like this:
   <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>/mnt/home:
        dev             =3D "/home"
        vfs             =3D nfs
        nodename        =3D master.foo.com
        mount           =3D true
        options         =3D bg,hard,intr,rsize=3D1024,wsize=3D1024,vers=3D2=
,proto=3Dudp
        account         =3D false
  </PRE
></FONT
></TD
></TR
></TABLE
>
  </P
><P
>   <P
></P
><OL
TYPE=3D"i"
><LI
><P
>       Version 4.3.2 of AIX, and possibly earlier versions as well,
       requires that file systems be exported with
       the <TT
CLASS=3D"USERINPUT"
><B
>insecure</B
></TT
> option, which=20
       causes NFS to listen to requests from=20
       insecure ports (i.e., ports above 1024, to which non-root users can=20
       bind).  Older versions of AIX do not seem to require this.
     </P
></LI
><LI
><P
>       AIX clients will default to mounting version 3 NFS over TCP.
       If your Linux server does not support this, then you may need
       to specify <TT
CLASS=3D"USERINPUT"
><B
>vers=3D2</B
></TT
> and/or=20
       <TT
CLASS=3D"USERINPUT"
><B
>proto=3Dudp</B
></TT
> in your mount options.
     </P
></LI
><LI
><P
>       Using netmasks in <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
>
       seems to sometimes cause clients
       to lose mounts when another client is reset.  This can be fixed
       by listing out hosts explicitly.
     </P
></LI
><LI
><P
>       Apparently automount in AIX 4.3.2 is rather broken.
     </P
></LI
></OL
>
 </P
></DIV
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"BSD"
>8.2. BSD</A
></H2
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"BSDSERVER"
>8.2.1. BSD servers and Linux clients</A
></H3
><P
>       BSD kernels tend to work better with larger block sizes.
     </P
></DIV
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"BSDCLIENT"
>8.2.2. Linux servers and BSD clients</A
></H3
><P
>       Some versions of BSD may make requests to the server from insecure =
ports,
       in which case you will need to export your volumes with the=20
       <TT
CLASS=3D"USERINPUT"
><B
>insecure</B
></TT
>
       option.  See the man page for <EM
>exports(5)</EM
>=20
       for more details.
     </P
></DIV
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"TRU64"
>8.3. Compaq Tru64 Unix</A
></H2
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"TRU64SERVER"
>8.3.1. Tru64 Unix Servers and Linux Clients</A
></H3
><P
>      In general, Tru64 Unix servers work quite smoothly with Linux client=
s.
      The format for the <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> file for our example in <A
HREF=3D"server.html"
>Section 3</A
> is:
   <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>    =20
/usr         slave1.foo.com:slave2.foo.com \
     -access=3Dslave1.foo.com:slave2.foo.com \

/home        slave1.foo.com:slave2.foo.com \
         -rw=3Dslave1.foo.com:slave2.foo.com \
       -root=3Dslave1.foo.com:slave2.foo.com=20
   </PRE
></FONT
></TD
></TR
></TABLE
>
   </P
><P
> (The <TT
CLASS=3D"USERINPUT"
><B
>root</B
></TT
> option is listed in the last=20
 entry for informational purposes only; its use is not recommended
 unless necessary.)
     </P
><P
>     Tru64 checks the <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> file every time there is a mount request
     so you do not need to run the <B
CLASS=3D"COMMAND"
>exportfs</B
> command; in fact on many
     versions of Tru64 Unix the command does not exist.
    </P
></DIV
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"TRU64CLIENT"
>8.3.2. Linux Servers and Tru64 Unix Clients</A
></H3
><P
>      There are two issues to watch out for here.  First, Tru64 Unix mount=
s
      using Version 3 NFS by default.  You will see mount errors if your
      Linux server does not support Version 3 NFS.  Second, in Tru64 Unix
      4.x, NFS locking requests are made by=20
      <TT
CLASS=3D"COMPUTEROUTPUT"
>daemon</TT
>.  You will therefore
      need to specify the <TT
CLASS=3D"USERINPUT"
><B
>insecure_locks</B
></TT
> option on all volumes you export
      to a Tru64 Unix 4.x client; see the <B
CLASS=3D"COMMAND"
>exports</B
> man pages for details.
    </P
></DIV
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"HPUX"
>8.4. HP-UX</A
></H2
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"HPUXSERVER"
>8.4.1. HP-UX Servers and Linux Clients</A
></H3
><P
>       A sample <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> entry on HP-UX looks like this:
    <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>/usr -ro,access=3Dslave1.foo.com:slave2.foo.com
/home -rw=3Dslave1.foo.com:slave2.fo.com:root=3Dslave1.foo.com:slave2.foo.c=
om
    </PRE
></FONT
></TD
></TR
></TABLE
>
       (The <TT
CLASS=3D"USERINPUT"
><B
>root</B
></TT
> option is listed in the last entry for informational
       purposes only; its use is not recommended unless necessary.)
     </P
></DIV
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"HPUXCLIENT"
>8.4.2. Linux Servers and HP-UX Clients</A
></H3
><P
>     HP-UX diskless clients will require at least a kernel version 2.2.19
     (or patched 2.2.18) for device files to export correctly.  Also, any
     exports to an HP-UX client will need to be exported with the=20
     <TT
CLASS=3D"USERINPUT"
><B
>insecure_locks</B
></TT
> option.
   </P
></DIV
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"IRIX"
>8.5. IRIX</A
></H2
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"IRIXSERVER"
>8.5.1. IRIX Servers and Linux Clients</A
></H3
><P
>    A sample <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> entry on IRIX looks like this:
  <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>/usr -ro,access=3Dslave1.foo.com:slave2.foo.com
/home -rw=3Dslave1.foo.com:slave2.fo.com:root=3Dslave1.foo.com:slave2.foo.c=
om
  </PRE
></FONT
></TD
></TR
></TABLE
>
    (The <TT
CLASS=3D"USERINPUT"
><B
>root</B
></TT
> option is listed in the last entry for informational
    purposes only; its use is not recommended unless necessary.)
  </P
><P
>   There are reportedly problems when using the nohide option on
   exports to linux 2.2-based systems.  This problem is fixed in the
   2.4 kernel.  As a workaround, you can export and mount lower-down
   file systems separately.
  </P
><P
>   As of Kernel 2.4.17, there continue to be several minor interoperabilit=
y
   issues that may require a kernel upgrade.  In particular:
  <P
></P
><UL
><LI
><P
>      Make sure that Trond Myklebust's <SPAN
CLASS=3D"APPLICATION"
>seekdir</SPAN
>=20
      (or <SPAN
CLASS=3D"APPLICATION"
>dir</SPAN
>) kernel patch is applied.
      The latest version (for 2.4.17) is located at:
     </P
><P
>      <A
HREF=3D"http://www.fys.uio.no/~trondmy/src/2.4.17/linux-2.4.17-seekdir.dif"
TARGET=3D"_top"
>      http://www.fys.uio.no/~trondmy/src/2.4.17/linux-2.4.17-seekdir.dif</=
A
>
     </P
></LI
><LI
><P
>      IRIX servers do not always use the same=20
      <TT
CLASS=3D"COMPUTEROUTPUT"
>fsid</TT
> attribute field across
      reboots, which results in <TT
CLASS=3D"COMPUTEROUTPUT"
>inode number mismatch</TT
>=20
      errors on a Linux
      client if the mounted IRIX server reboots. A patch is available from:
     </P
><P
><A
HREF=3D"http://www.geocrawler.com/lists/3/SourceForge/789/0/7777454/"
TARGET=3D"_top"
>      http://www.geocrawler.com/lists/3/SourceForge/789/0/7777454/</A
>
     </P
></LI
><LI
><P
>      Linux kernels v2.4.9 and above have problems reading large directori=
es
      (hundreds of files) from exported IRIX XFS file systems that were mad=
e
      with <TT
CLASS=3D"USERINPUT"
><B
>naming version=3D1</B
></TT
>. =20
      The reason for the problem can be found at:
     </P
><P
>      <A
HREF=3D"http://www.geocrawler.com/archives/3/789/2001/9/100/6531172/"
TARGET=3D"_top"
>       http://www.geocrawler.com/archives/3/789/2001/9/100/6531172/</A
>
     </P
><P
>       The naming version can be found by using (on the IRIX server):
     </P
><TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"90%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>	xfs_growfs -n mount_point
     </PRE
></FONT
></TD
></TR
></TABLE
><P
>=20
      The workaround is to export these file systems using the=20
      <TT
CLASS=3D"USERINPUT"
><B
>-32bitclients</B
></TT
>
      option in the <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> file.
      The fix is to convert the file system to 'naming version=3D2'.
      Unfortunately the only way to do this is by a=20
      <TT
CLASS=3D"USERINPUT"
><B
>backup</B
></TT
>/<TT
CLASS=3D"USERINPUT"
><B
>mkfs</B
></TT
>/<TT
CLASS=3D"USERINPUT"
><B
>restore</B
></TT
>.
      </P
><P
>       <B
CLASS=3D"COMMAND"
>mkfs_xfs</B
> on IRIX 6.5.14 (and above)=20
       creates <TT
CLASS=3D"USERINPUT"
><B
>naming version=3D2</B
></TT
> XFS file
       systems by default. On IRIX 6.5.5 to 6.5.13, use:
      <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"90%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>	mkfs_xfs -n version=3D2 device
      </PRE
></FONT
></TD
></TR
></TABLE
>
      </P
><P
>        Versions of IRIX prior to 6.5.5 do not support=20
        <TT
CLASS=3D"USERINPUT"
><B
>naming version=3D2</B
></TT
> XFS file systems.
      </P
></LI
></UL
>
   </P
></DIV
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"IRIXCLIENT"
>8.5.2. IRIX clients and Linux servers</A
></H3
><P
>   Irix versions up to 6.5.12 have problems mounting file systems exported
   from Linux boxes - the mount point "gets lost," e.g.,
  <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>	# mount linux:/disk1 /mnt
	# cd /mnt/xyz/abc
	# pwd
	/xyz/abc
   </PRE
></FONT
></TD
></TR
></TABLE
>
   </P
><P
>    This is known IRIX bug (SGI bug 815265 - IRIX not liking file handles =
of
    less than 32 bytes), which is fixed in <SPAN
CLASS=3D"APPLICATION"
>IRIX 6.5.13</SPAN
>.
    If it is not possible=20
    to upgrade to <SPAN
CLASS=3D"APPLICATION"
>IRIX 6.5.13</SPAN
>, then the unofficial=20
    workaround is to force the Linux <B
CLASS=3D"COMMAND"
>nfsd</B
>=20
    to always use 32 byte file handles.=20
   </P
><P
>    A number of patches exist - see:
   <P
></P
><UL
><LI
><P
>    <A
HREF=3D"http://www.geocrawler.com/archives/3/789/2001/8/50/6371896/"
TARGET=3D"_top"
>    http://www.geocrawler.com/archives/3/789/2001/8/50/6371896/</A
>
   </P
></LI
><LI
><P
>   <A
HREF=3D"http://oss.sgi.com/projects/xfs/mail_archive/0110/msg00006.html"
TARGET=3D"_top"
>    http://oss.sgi.com/projects/xfs/mail_archive/0110/msg00006.html</A
>
   </P
></LI
></UL
>
  </P
></DIV
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SOLARIS"
>8.6. Solaris</A
></H2
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"SOLARISSERVER"
>8.6.1. Solaris Servers</A
></H3
><P
>     Solaris has a slightly different format on the server end from
     other operating systems.  Instead of=20
     <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
>, the configuration
     file is <TT
CLASS=3D"FILENAME"
>/etc/dfs/dfstab</TT
>.  Entries are of=20
     the form of a <B
CLASS=3D"COMMAND"
>share</B
> command, where the syntax
     for the example in <A
HREF=3D"server.html"
>Section 3</A
> would look like
   <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>share -o rw=3Dslave1,slave2 -d "Master Usr" /usr
   </PRE
></FONT
></TD
></TR
></TABLE
>
     and instead of running <B
CLASS=3D"COMMAND"
>exportfs</B
> after editing, you run <B
CLASS=3D"COMMAND"
>shareall</B
>.
   </P
><P
>     Solaris servers are especially sensitive to packet size. If you
     are using a Linux client with a Solaris server, be sure to set
     <TT
CLASS=3D"USERINPUT"
><B
>rsize</B
></TT
> and <TT
CLASS=3D"USERINPUT"
><B
>wsize</B
></TT
>
     to 32768 at mount time.
   </P
><P
>     Finally, there is an issue with root squashing on Solaris: root gets
     mapped to the user <TT
CLASS=3D"COMPUTEROUTPUT"
>noone</TT
>, which=20
     is not the same as the user <TT
CLASS=3D"COMPUTEROUTPUT"
>nobody</TT
>.
     If you are having trouble with file permissions as root on the client
     machine, be sure to check that the mapping works as you expect.
   </P
></DIV
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"SOLARISCLIENT"
>8.6.2. Solaris Clients</A
></H3
><P
>     Solaris clients will regularly produce the following message:
    </P
><TABLE
BORDER=3D"1"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"SCREEN"
>svc: unknown program 100227 (me 100003)
  </PRE
></FONT
></TD
></TR
></TABLE
><P
>    This happens because Solaris clients, when they mount, try to obtain
    ACL information - which Linux obviously does not have. The messages
    can safely be ignored.=20
  </P
><P
>    There are two known issues with diskless Solaris clients: First, a ker=
nel
    version of at least 2.2.19 is needed to get <TT
CLASS=3D"FILENAME"
>/dev/null</TT
> to export=20
    correctly.  Second, the packet size may need to be set extremely
    small (i.e., 1024) on diskless sparc clients because the clients
    do not know how to assemble packets in reverse order.  This can be
    done from <TT
CLASS=3D"FILENAME"
>/etc/bootparams</TT
> on the clients.
   </P
></DIV
></DIV
><DIV
CLASS=3D"SECT2"
><H2
CLASS=3D"SECT2"
><A
NAME=3D"SUNOS"
>8.7. SunOS</A
></H2
><P
>    SunOS only has NFS Version 2 over UDP.
  </P
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"SUNOSSERVER"
>8.7.1. SunOS Servers</A
></H3
><P
>     On the server end, SunOS uses the most traditional format for its=20
     <TT
CLASS=3D"FILENAME"
>/etc/exports</TT
> file. The example in <A
HREF=3D"server.html"
>Section 3</A
> would look like:
   <TABLE
BORDER=3D"0"
BGCOLOR=3D"#E0E0E0"
WIDTH=3D"100%"
><TR
><TD
><FONT
COLOR=3D"#000000"
><PRE
CLASS=3D"PROGRAMLISTING"
>/usr    -access=3Dslave1.foo.com,slave2.foo.com
/home   -rw=3Dslave1.foo.com,slave2.foo.com, root=3Dslave1.foo.com,slave2.f=
oo.com
   </PRE
></FONT
></TD
></TR
></TABLE
>
  </P
><P
>   Again, the <TT
CLASS=3D"USERINPUT"
><B
>root</B
></TT
> option is listed for informational
   purposes and is not recommended unless necessary.
  </P
></DIV
><DIV
CLASS=3D"SECT3"
><H3
CLASS=3D"SECT3"
><A
NAME=3D"SUNOSCLIENT"
>8.7.2. SunOS Clients</A
></H3
><P
>    Be advised that SunOS makes all NFS locking requests=20
    as <TT
CLASS=3D"COMPUTEROUTPUT"
>daemon</TT
>, and=20
    therefore you will need to add the <TT
CLASS=3D"USERINPUT"
><B
>insecure_locks</B
></TT
> option to any=20
    volumes you export to a SunOS machine.  See the <B
CLASS=3D"COMMAND"
>exports</B
> man page
    for details.
  </P
></DIV
></DIV
></DIV
><DIV
CLASS=3D"NAVFOOTER"
><HR
ALIGN=3D"LEFT"
WIDTH=3D"100%"><TABLE
WIDTH=3D"100%"
BORDER=3D"0"
CELLPADDING=3D"0"
CELLSPACING=3D"0"
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
><A
HREF=3D"troubleshooting.html"
>Prev</A
></TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
><A
HREF=3D"index.html"
>Home</A
></TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
>&nbsp;</TD
></TR
><TR
><TD
WIDTH=3D"33%"
ALIGN=3D"left"
VALIGN=3D"top"
>Troubleshooting</TD
><TD
WIDTH=3D"34%"
ALIGN=3D"center"
VALIGN=3D"top"
>&nbsp;</TD
><TD
WIDTH=3D"33%"
ALIGN=3D"right"
VALIGN=3D"top"
>&nbsp;</TD
></TR
></TABLE
></DIV
></BODY
></HTML
>
--=-DzUZBAgzdIo18XiQgRt5--

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
