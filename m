From: Daniel Phillips <phillips@google.com>
Subject: Re: Lock recursion in rpc_pipefs+auth_gss...
Date: Thu, 19 Jan 2006 11:27:03 -0800
Message-ID: <43CFE807.5080304@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EzfR9-0007Hd-Fl
	for nfs@lists.sourceforge.net; Thu, 19 Jan 2006 11:27:11 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EzfR8-0005IM-9d
	for nfs@lists.sourceforge.net; Thu, 19 Jan 2006 11:27:11 -0800
To: Trond Myklebust <Trond.Myklebust@netapp.com>
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

Hi Trond,

You wrote:
 > I believe I've finally figured out what is causing the Oopses that Vince
 > and Vincent were seeing. It all boils down to a mutex being held after
 > the inode is released due to a deadlock situation.

That in itself should not cause an oops.  I would think there is a
reference-counting problem still lurking.  I'm a little concerned that a
patch like this one may just make the oops a lot rarer without solving it.

Regards,

Daniel


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
