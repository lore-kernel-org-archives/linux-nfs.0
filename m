From: Kirk Ismay <captain@netidea.com>
Subject: Linux NFS Client ignores quotas
Date: Tue, 17 Jan 2006 12:33:02 -0800
Message-ID: <43CD547E.9080808@netidea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EyxZW-0005Hu-54
	for nfs@lists.sourceforge.net; Tue, 17 Jan 2006 12:36:54 -0800
Received: from [207.194.161.10] (helo=nola.netidea.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EyxZO-0000uV-Qk
	for nfs@lists.sourceforge.net; Tue, 17 Jan 2006 12:36:51 -0800
Received: from [192.168.100.206] (ymir.netidea.com [66.244.242.8] (may be forged))
	(authenticated bits=0)
	by nola.netidea.com (8.13.4/8.13.4/Debian-3) with ESMTP id k0HKaimr016814
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Tue, 17 Jan 2006 12:36:45 -0800
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

I have an nfs client that mounts /home from another linux file server. 
Both run Linux 2.4.25 kernels on Debian woody. Quotas are enabled for 
/home and are working properly on the server, but on the client they are 
ignored.

If I log in as a user who is over quota (about 300MB over quota, and the 
grace period has expired) on the client and copy a file, it succeeds. I 
can also modify any of the files.

The nfs server is:
/usr/sbin/rpc.nfsd --version
Universal NFS Server 2.2beta47

I'm not sure when this stopped working. I would appreciate suggestions 
on how to track down the source of the problem.

Let me know if additional information is needed.

Thanks.

-- 
Sincerely,
Kirk Ismay
System Administrator

--
Net Idea
201-625 Front Street Nelson, BC V1L 4B6
P:250-352-3512 | F:250-352-9780 | TF:888-246-4222

10 Years of Service Excellence!

Visit us online at:
www.netidea.com | www.netidea.biz


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
