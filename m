From: devzero@web.de
Subject: nfs exports & bind mounts
Date: Sat, 10 Nov 2007 22:36:45 +0100
Message-ID: <2077779951@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi !

i think everybody knows bind mounts.

i can do:

touch /otherpath/dummyfile
mount -bind /path/file /otherpath/dummyfile

so /path/file becomes accessible via /otherpath/dummyfile - dummyfile has the same size as file after successful bind-mount

i can loopback-mount /otherpath/dummyfile to /otherpath/mnt if file/dummyfile contains a filesystem

when i export /otherpath via nfs (crossmnt), from the client side i can access the contents of the filesystem inside file/dummyfile via /otherpath/mnt  - but i cannot access the contents of dummyfile itself, i.e. the bind-mount seems to get lost on export.

can someone tell if this is expected behaviour or if this is a bug ?

regards
roland
_____________________________________________________________________
Der WEB.DE SmartSurfer hilft bis zu 70% Ihrer Onlinekosten zu sparen!
http://smartsurfer.web.de/?mc=100071&distributionid=000000000066


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
