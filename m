From: jiangwr <jiangwr@asiainfo.com>
Subject: did nfs cache file content in memory?
Date: Thu, 30 May 2002 14:05:26 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <19399885918.20020530140526@asiainfo.com>
Reply-To: jiangwr <jiangwr@asiainfo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [211.100.11.6] (helo=aints2.asiainfo.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17DJ4w-0000hw-00
	for <nfs@lists.sourceforge.net>; Wed, 29 May 2002 23:06:30 -0700
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


Hello nfs-lister,

      I am setting up a nfs server on redhat 7.2(kernel 2.4.7-10/nfs-util 0.3.1),the machine
      is a intel PIII with 1G memory.the nfs server works fine,but if client machine create a
      10M file in nfs-mounted directory,then the server's used memory goes up 10M,removing the
      same 10M file will drop the server's used memory 10M too.using `cat /proc/meminfo` the
      Inact_dirty field also confirm this.
      my problem is:as the memory keeps going,it will soon eat up all my free memory and the lockd
      will get core dump,and the server need reboot.
      my question is:is this a feature or a bug?did nfs really cache file content in memory?Do I
      have a option to disable this or where to find a memory cleaner so I can long-run this server
      without rebooting it every several hours.

Best regards,
 jiangwr                          mailto:jiangwr@asiainfo.com

============================
½­ÎµÈ»(Jerry Jiang)
Asiainfo GuangZhou Office
Phone:(020)87310203-8521


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
