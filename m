From: Peter Staubach <staubach@redhat.com>
Subject: Re: Some code, and a question
Date: Wed, 07 Sep 2005 13:25:56 -0400
Message-ID: <431F22A4.8000007@redhat.com>
References: <1126046397.3000.188.camel@seki.nac.uci.edu>	 <20050907010219.GA14233@sgi.com>	 <1126103821.16701.8.camel@seki.nac.uci.edu>  <431EFF78.6000709@redhat.com> <1126112442.16701.17.camel@seki.nac.uci.edu> <431F1FD5.4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Greg Banks <gnb@sgi.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ED3l0-00087v-Oo
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 10:30:46 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ED3kz-0007L8-Er
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 10:30:46 -0700
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <431F1FD5.4@redhat.com>
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

Peter Staubach wrote:

>>
>> No I haven't - great lead.  I'll see if I can google that up.  Or if you
>> have the incantation at your fingertips...
>>
>
> For Solaris, you might check out adding something like:
>
>    set nfs:nfs3_max_transfer_size=1048576
>    set nfs:nfs4_max_transfer_size=1048576
>
> to /etc/system and then reboot the system.  This will increase the 
> maximum
> size of a transfer to 1M.  Alternately, you could use adb to patch a 
> running
> system.  The command, "nfsstat -m", should tell you what the limits 
> are for
> currently mounted file systems.  You will need to umount and mount any
> existing NFS mounted file systems in order for them to be able to use the
> new limits. 


You will probably need to increase the NFS client side blocksize
as well.  This is nfs[34]_bsize.  So, something like:

    set nfs:nfs3_bsize=1048576
    set nfs:nfs4_bsize=1048576

although, you will probably want it to match your rsize/wsize settings.

Please be aware that the if the block size is bigger than the transfer
size, then the Solaris NFS client will do break up the block sized
transfers into multiple pieces and then do them sequentially.

So, there is a tie between the read transfer size and the write transfer
size, at least on a Solaris client.

    Thanx...

       ps


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
