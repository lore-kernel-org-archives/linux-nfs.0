From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils - Silencing mountd
Date: Thu, 17 Jun 2004 15:00:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40D1EA4A.6080002@RedHat.com>
References: <40D063D1.9010208@RedHat.com> <20040616224504.GB29503@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bb27L-0006Dm-9W
	for nfs@lists.sourceforge.net; Thu, 17 Jun 2004 12:00:07 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1Bb27K-00005w-TH
	for nfs@lists.sourceforge.net; Thu, 17 Jun 2004 12:00:06 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040616224504.GB29503@sgi.com>
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

Greg Banks wrote:

>Actually, I find the "authenticated mount request from..."  message
>useful in tracking down strange but nonfatal bugs on busy servers with
>many mounts from many clients.  Not all NFS or RPC error messages
>tell you which client was involved, so correlating those messages
>with mount messages can help narrow the list.
>  
>
True... the authenticated message is a good way to see that
a client is able to communicate with the server... but
in reality it doesn't mean much... and every error message
in the same code path (i.e. in  auth_authenticate()) gives a pretty
detail error message of who and what happen..


SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
