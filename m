From: James Pearson <james-p@moving-picture.com>
Subject: Re: file :"/var/lib/nfs/rmtab"
Date: Fri, 04 Feb 2005 10:04:17 +0000
Message-ID: <420348A1.5020804@moving-picture.com>
References: <20050204050123.69399.qmail@web51610.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cx0K6-0004WT-DL
	for nfs@lists.sourceforge.net; Fri, 04 Feb 2005 02:04:22 -0800
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cx0K4-0004jv-Km
	for nfs@lists.sourceforge.net; Fri, 04 Feb 2005 02:04:22 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050204050123.69399.qmail@web51610.mail.yahoo.com>
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

Did you do 'mount -t nfsd nfsd /proc/fs/nfsd' before starting all the 
nfs daemons?

James Pearson

mehta kiran wrote:
> I am using 2.6 kernel
> --- mehta kiran <kiranmehta1981@yahoo.com> wrote:
> 
> 
>>Hi , 
>>         if handle supplied by client is sufficient
>>,
>> then why does the problem given below exists.
>>
>>1. export filesystem to client.
>>2. let client allow to mount it.
>>3. remove all entries from rmtab on server.
>>4. restart all nfs daemons.
>>5. Now if client access filesystem , it gets
>>   permission denied error.Client can access
>>   filesystem only after remounting it.
>>6. This show that mountd still uses rmtab to
>>   check if client had mounted filesystem or not.
>>   No entry in rmtab for a client means it has not
>>   mounted filesystem.
>>
>>thanks,
>> --kiran
>>
>>--- Paul Clements <paul.clements@steeleye.com>
>>wrote:
>>
>>
>>>mehta kiran wrote:
>>>
>>>
>>>>Isn't handle supplied by client
>>>>          enough to verify clients access to
>>>>          filesystem.?
>>>
>>>Yes, it should be. That's why in 2.6, the rmtab
>>
>>file
>>
>>>is no longer relied 
>>>upon. Instead, there is a special filesystem,
>>>/proc/fs/nfsd, that allows 
>>>the kernel to communicate with mountd in order to
>>>authenticate 
>>>unrecognized clients automatically.
>>>
>>>--
>>>Paul
>>>
>>>
>>>
>>
> -------------------------------------------------------
> 
>>>This SF.Net email is sponsored by: IntelliVIEW --
>>>Interactive Reporting
>>>Tool for open source databases. Create drag-&-drop
>>>reports. Save time
>>>by over 75%! Publish reports on the web. Export to
>>>DOC, XLS, RTF, etc.
>>>Download a FREE copy at
>>>http://www.intelliview.com/go/osdn_nl
>>>_______________________________________________
>>>NFS maillist  -  NFS@lists.sourceforge.net
>>>https://lists.sourceforge.net/lists/listinfo/nfs
>>>
>>
>>
>>
>>	
>>		
>>__________________________________ 
>>Do you Yahoo!? 
>>Yahoo! Mail - You care about security. So do we. 
>>http://promotions.yahoo.com/new_mail
>>
>>
>>
> 
> -------------------------------------------------------
> 
>>This SF.Net email is sponsored by: IntelliVIEW --
>>Interactive Reporting
>>Tool for open source databases. Create drag-&-drop
>>reports. Save time
>>by over 75%! Publish reports on the web. Export to
>>DOC, XLS, RTF, etc.
>>Download a FREE copy at
>>http://www.intelliview.com/go/osdn_nl
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>
> 
> 
> 
> 
> 		
> __________________________________ 
> Do you Yahoo!? 
> Meet the all-new My Yahoo! - Try it today! 
> http://my.yahoo.com 
>  
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
> Tool for open source databases. Create drag-&-drop reports. Save time
> by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
> Download a FREE copy at http://www.intelliview.com/go/osdn_nl
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
