From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: Re: Lock recursion in rpc_pipefs+auth_gss...
Date: Thu, 19 Jan 2006 18:09:36 -0500
Message-ID: <1137712176.11182.20.camel@lade.trondhjem.org>
References: <43CFE807.5080304@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eziuf-0001M4-5Q
	for nfs@lists.sourceforge.net; Thu, 19 Jan 2006 15:09:53 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Eziud-0003rN-Qf
	for nfs@lists.sourceforge.net; Thu, 19 Jan 2006 15:09:53 -0800
To: Daniel Phillips <phillips@google.com>
In-Reply-To: <43CFE807.5080304@google.com>
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

On Thu, 2006-01-19 at 11:27 -0800, Daniel Phillips wrote:

> That in itself should not cause an oops.  I would think there is a
> reference-counting problem still lurking.  I'm a little concerned that a
> patch like this one may just make the oops a lot rarer without solving it.

The lock recursion is _real_: I've been able to trigger it on
2.6.16-rc1. The only question here is therefore whether or not it
suffices to explain the Oops.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
