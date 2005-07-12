From: Nick Wilson <njw@osdl.org>
Subject: Re: [PATCH 3/3]: NFS: Introduce the use of inode->i_lock to protect fields in nfsi
Date: Tue, 12 Jul 2005 09:52:47 -0700
Message-ID: <20050712165247.GA9097@njw.pdx.osdl.net>
References: <482A3FA0050D21419C269D13989C611308539D87@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsNx8-0002Xj-Hf
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 09:49:50 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DsNx7-0008BD-Bs
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 09:49:50 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611308539D87@lavender-fe.eng.netapp.com>
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

On Sat, Jul 09, 2005 at 08:33:58AM -0700, Lever, Charles wrote:
>  Down the road we want to eliminate the use of the global kernel lock
>  entirely from the NFS client.  To do this, we need to protect the fields
>  in the nfs_inode structure adequately.  Start by serializing updates to
>  the "cache_validity" field.
> 
>  Note this change addresses an SMP hang found by njw@osdl.org, where
>  processes deadlock because nfs_end_data_update and nfs_revalidate_mapping
>  update the "cache_validity" field without proper serialization.
> 
>  Test plan:
>  Millions of fsx ops on SMP clients.  Run Nick Wilson's breaknfs program on
>  large SMP clients.

breaknfs has been running fine on an 8-way for nearly 24 hours.
Considering it locks up in minutes without these patches, I'd say that
these fix my problem :)

Nick Wilson


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
