From: David Chow <davidchow@shaolinmicro.com>
Subject: Re: NFSv4 pseudo filesystem
Date: Sun, 12 May 2002 01:39:58 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <abjl56$dri$2@main.gmane.org>
References: <Pine.SOL.4.44.0205101340370.27306-100000@mspacman.gpcc.itd.umich.edu> <15580.47791.999102.980645@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "Kendrick M. Smith" <kmsmith@umich.edu>,  nfs@lists.sourceforge.net,
 linux-fsdevel@vger.kernel.org,  nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from aries.i-cable.com ([210.80.60.86])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 176aqi-0000uj-00
	for <nfs@lists.sourceforge.net>; Sat, 11 May 2002 10:40:04 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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

Neil Brown wrote:

>On Friday May 10, kmsmith@umich.edu wrote:
>
>>  Proposal 3: Build up the pseudofs inside the 2.5 'nfsd' filesystem,
>>  say in a directory nfsd/pseudofs which is created when the nfsd
>>  filesystem is mounted.  The exportfs utility would be responsible
>>  for creating the necesary subdirectories, then hanging the exports
>>  off the leaves with mount --bind, before starting nfsd.
>>
>>As I see it, the disadvantage of proposal 3 is that it is a little
>>tricky to construct persistent filehandles ("persistent" in the sense
>>that an old filehandle is still recognize after the server is rebooted).
>>One solution would be to use an MD5 or SHA hash of the pathname as the
>>filehandle.  The hash could be computed in userspace and passed into
>>the kernel somehow.
>>
>
>I would go for 3, and don't care about persistent file handles.  Just
>use volatile filehandles for this bit of the namespace.
>
>NeilBrown
>-
>To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
I am a bit confused about compatibility of NFSv3, doesn't the nohide 
option allow to trigger an exported fs's (dir) subdirectory mount points 
to be automatically mounted by clients? If 2.5 is proposing the arbitary 
(fs=somepersistentnumber), how nohide is going to know whether the next 
fs's number? It is clear in 2.4 now we use the device major and minor 
numbers such that only block device fs are exportable. I think there 
were a long discussion about the fs= months ago to allow exporting non 
block device fs. I have worked hard on making my fs a fake block device 
fs in 2.4 which uses an arbitary block device number, but I don't think 
it is a good idea to drop the fs= implementation because many times we 
want to export non block device fs with a persisten t file handle. I 
don't think using arbitary devices for just because want to cope with 
NFS is a good idea. I think many of the system rely on the stateless and 
persistent design of NFS, since NFS is a de facto standard for Unixes, I 
am not happy to see NFSv4 break this.


regards,

David


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
