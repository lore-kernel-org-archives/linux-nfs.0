From: Steve Dickson <SteveD@redhat.com>
Subject: Re: statd simplified
Date: Tue, 03 Feb 2004 10:47:30 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <401FC292.9030303@RedHat.com>
References: <20040202140851.GH3145@suse.de> <401E8F6B.5040400@RedHat.com> <20040203101733.GB26315@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ao3ls-0007tE-Nz
	for nfs@lists.sourceforge.net; Tue, 03 Feb 2004 08:51:32 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Ao2ld-0001sH-9O
	for nfs@lists.sourceforge.net; Tue, 03 Feb 2004 07:47:13 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040203101733.GB26315@suse.de>
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

Hello,

Olaf Kirch wrote:

>On Mon, Feb 02, 2004 at 12:56:59PM -0500, Steve Dickson wrote:
>  
>
>>Letting /var/lib/nfs/sm grow uncontrollably (i.e. not using SM_UNMON to
>>clean it up) may not be a good idea... Since users can't go in and clean 
>>in up by hand
>>(since they could be removing live state), there probably should be some
>>way to cleaned up (and up to date)
>>    
>>
>
>Okay, I could add that. Calling unlink from kernel space is a bit of
>a nuisance, but I'll try :)
>  
>
Maybe the user level daemon could be used to do this....
When an SM_UNMON comes in, the kernel could clean up its
state and then forward the message to the daemon that would
cause the file to be removed...

SteveD.



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
