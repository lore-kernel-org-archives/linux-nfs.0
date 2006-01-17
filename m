From: Kirk Ismay <captain@netidea.com>
Subject: Re: Linux NFS Client ignores quotas
Date: Tue, 17 Jan 2006 13:25:20 -0800
Message-ID: <43CD60C0.9050202@netidea.com>
References: <43CD547E.9080808@netidea.com> <1137530743.7855.162.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EyyO7-0007jG-Jt
	for nfs@lists.sourceforge.net; Tue, 17 Jan 2006 13:29:11 -0800
Received: from [207.194.161.10] (helo=nola.netidea.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EyyO6-0003BT-7W
	for nfs@lists.sourceforge.net; Tue, 17 Jan 2006 13:29:11 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1137530743.7855.162.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> On Tue, 2006-01-17 at 12:33 -0800, Kirk Ismay wrote:
> 
>>I have an nfs client that mounts /home from another linux file server. 
>>Both run Linux 2.4.25 kernels on Debian woody. Quotas are enabled for 
>>/home and are working properly on the server, but on the client they are 
>>ignored.
> 
> 
> The NFS protocol has no support for quotas. It is up to the server to
> enforce those, not the client.
> 

Thanks for the hint. Changing to the kernel nfs server did the trick.

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
