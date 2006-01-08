From: Blake Golliher <golliher@yahoo-inc.com>
Subject: Re: NFS performance tuning
Date: Sat, 7 Jan 2006 23:44:21 -0800
Message-ID: <06259ef940d5d01fc15319edce982acc@local>
References: <43BE9EC3.3090108@totalflood.com> <32f0438a5087c2ea289922bbacb1897d@local> <Pine.LNX.4.64.0601081449320.19300@eagle.themaw.net>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: Stephen Carville <stephen@totalflood.com>,
	NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EvVEP-0001L1-1N
	for nfs@lists.sourceforge.net; Sat, 07 Jan 2006 23:44:49 -0800
Received: from mrout1-b.corp.dcn.yahoo.com ([216.109.112.27])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EvVEN-0003Kw-PP
	for nfs@lists.sourceforge.net; Sat, 07 Jan 2006 23:44:49 -0800
In-Reply-To: <Pine.LNX.4.64.0601081449320.19300@eagle.themaw.net>
To: Ian Kent <raven@themaw.net>
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


On Jan 7, 2006, at 10:51 PM, Ian Kent wrote:

> On Fri, 6 Jan 2006, Blake Golliher wrote:
>
>> Did you specify using a 32k read and write size, that I didn't see 
>> somewhere?
>> If you have a very clean network, you could get an advantage of using 
>> UDP as
>> well.  I'm not sure which transport you are using though.
>>
>> Oh I see a mention of nfs v2 tcp.  Well, I'd recommend moving to nfs 
>> v3, using
>> a 64k read/write size, and using UDP.  That might give you some 
>> gains.  Of
>> course, I'm usually a TCP bigot for nfs transport, but for a very 
>> clean,
>> almost back to back, dedicated switch type of environment, I'll allow 
>> it.
>
> Mmm. I thought UDP was max. 8k read and write size and 32k was the max.
> for TCP.

The linux nfs client supports, at least, a 64k block transfer size.  I 
don't believe it's constrained by transport protocol.

-Blake



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
