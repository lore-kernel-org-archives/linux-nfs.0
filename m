From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: binaries becoming corrupt on nfs
Date: Mon, 14 Mar 2005 14:43:53 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0503141440310.4702@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0503141414590.4702@harp.ngdc.noaa.gov>
 <20050314213513.GL32463@hmsendeavour.rdu.redhat.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAxM0-0002PQ-9N
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 13:44:00 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAxLy-0002pX-Rb
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 13:44:00 -0800
To: nhorman@redhat.com
In-Reply-To: <20050314213513.GL32463@hmsendeavour.rdu.redhat.com>
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

On Mon, 14 Mar 2005 nhorman@redhat.com wrote:

> On Mon, Mar 14, 2005 at 02:25:30PM -0700, Ara.T.Howard wrote:
>>
>> we are seeing some really bizarre strange behaviour on our nfs systems.
>> essentially a system will hum along nicely, running binaries from our nfs
>> server without issue.  for no apparent reason these binaries suddenly become
>> corrupt on the client side and stop working.  running md5sum on the affected
>> binary on a 'good' host and a 'bad' one shows them to, in fact, be
>> different.
>>
>> doing and unmount and remount fixes the issue.  obviously so does a reboot.
>> both are temporary fixes though - eventually a node will start getting
>> corrupt
>> binaries - or perhaps not.
>>
>> the server is not under undue stress as it serves only code and no data
>> traffic is hitting it (we use vsftp to move data around).  none of the
>> machines seems to logging any errors - server nor client.  all of our
>> systems
>> are the same:
>>
>>   ~ > uname -srm
>>   Linux 2.4.21-27.0.2.EL i686
>>
>>   ~ > cat /etc/redhat-release
>>   Red Hat Enterprise Linux WS release 3 (Taroon Update 4)
>>

> If you're only serving code can you try mounting the share Read Only from
> all your clients?

well - almost only code.  sometimes we have a little sqlite database which is
being used as a job queue and this is being written to.  it's not at the
moment however so we could try this in the short term for testing...

one other tidbit.  last week i froze one of our boxes a few times in a row by
simply do a compile in an nfs mounted directory (writing lots of files).  i
could reproduce this at will - but on no other boxes that i tested.  now that
i see that boxes are failing randomly i think i should have tested this on
more boxes - i only tried two - but it's pain because it causes the box to
hang on any operation related to nfs and then needs rebooted....

cheers.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
