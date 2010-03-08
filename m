From: Steve Dickson <SteveD@redhat.com>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Mon, 08 Mar 2010 12:42:42 -0500
Message-ID: <4B953712.3090703@RedHat.com>
References: <4B7D4E55.4040002@RedHat.com>
	<20100304201941.GL19154@ics.muni.cz>	<4B9021EF.60309@oracle.com>
	<20100304212149.GM19154@ics.muni.cz>	<4B903485.1030608@oracle.com>
	<20100304224011.GN19154@ics.muni.cz>	<20100308101607.GR19154@ics.muni.cz>	<20100308070209.7cabb55f@tlielax.poochiereds.net>	<20100308121117.GW19154@ics.muni.cz>
	<4d569c331003080544n40a12f52x74b39420a697e546@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, NFSv3 list <linux-nfs@vger.kernel.org>,
	Jeff Layton <jlayton@redhat.com>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4d569c331003080544n40a12f52x74b39420a697e546@mail.gmail.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/08/2010 08:44 AM, Kevin Coffman wrote:
> 2010/3/8 Lukas Hejtmanek <xhejtman@ics.muni.cz>:
>> On Mon, Mar 08, 2010 at 07:02:09AM -0500, Jeff Layton wrote:
>>> (cc'ing Olga)
>>>
>>> Hmm....gssd in 1.2.2 seems to work fine for me. The only changes in
>>> that area of the code were some of Olga's patches that went into 1.2.2.
>>> Olga, any thoughts?
>>
>> It does not work for me and for one student that works on some patches.
>>
>> We both have an issue with compilation as well as I mentioned earlier.
>>
>>> Lukas, could you also tell us what kernel you're using, and maybe send
>>> the output of ldd against the binary?
>>
>> My kernel is 2.6.33. The student's kernel is about 2.6.31 or 2.6.32.
>>
>> ldd /tmp/nfs-utils-1.2.2/utils/gssd/gssd
>>        linux-vdso.so.1 =>  (0x00007fff317ed000)
>>        libgssapi_krb5.so.2 => /usr/lib/libgssapi_krb5.so.2 (0x00007faa7c631000)
>>        libkrb5.so.3 => /usr/lib/libkrb5.so.3 (0x00007faa7c36d000)
>>        libk5crypto.so.3 => /usr/lib/libk5crypto.so.3 (0x00007faa7c146000)
>>        libcom_err.so.2 => /lib/libcom_err.so.2 (0x00007faa7bf42000)
>>        librpcsecgss.so.3 => /usr/lib/librpcsecgss.so.3 (0x00007faa7bd32000)
>>        libgssglue.so.1 => /usr/lib/libgssglue.so.1 (0x00007faa7bb27000)
>>        libdl.so.2 => /lib/libdl.so.2 (0x00007faa7b923000)
>>        libc.so.6 => /lib/libc.so.6 (0x00007faa7b5a2000)
>>        libkrb5support.so.0 => /usr/lib/libkrb5support.so.0 (0x00007faa7b399000)
>>        libkeyutils.so.1 => /lib/libkeyutils.so.1 (0x00007faa7b196000)
>>        libresolv.so.2 => /lib/libresolv.so.2 (0x00007faa7af7d000)
>>        libpthread.so.0 => /lib/libpthread.so.0 (0x00007faa7ad5f000)
>>        /lib64/ld-linux-x86-64.so.2 (0x00007faa7c886000)
The kernel the package was tested was a  2.6.33-ish kernel 
and here is what my rpc.gssd is linked against... 

# ldd /usr/sbin/rpc.gssd 
	linux-vdso.so.1 =>  (0x00007fff283ff000)
	libgssglue.so.1 => /usr/lib64/libgssglue.so.1 (0x00007fda41062000)
	libdl.so.2 => /lib64/libdl.so.2 (0x00007fda40e5e000)
	libgssapi_krb5.so.2 => /lib64/libgssapi_krb5.so.2 (0x00007fda40c29000)
	libkrb5.so.3 => /lib64/libkrb5.so.3 (0x00007fda4095f000)
	libk5crypto.so.3 => /lib64/libk5crypto.so.3 (0x00007fda40738000)
	libcom_err.so.2 => /lib64/libcom_err.so.2 (0x00007fda40535000)
	libtirpc.so.1 => /usr/lib64/libtirpc.so.1 (0x00007fda4030e000)
	libc.so.6 => /lib64/libc.so.6 (0x00007fda3ff8c000)
	/lib64/ld-linux-x86-64.so.2 (0x00007fda4126b000)
	libkrb5support.so.0 => /lib64/libkrb5support.so.0 (0x00007fda3fd83000)
	libkeyutils.so.1 => /lib64/libkeyutils.so.1 (0x00007fda3fb81000)
	libresolv.so.2 => /lib64/libresolv.so.2 (0x00007fda3f967000)
	libpthread.so.0 => /lib64/libpthread.so.0 (0x00007fda3f74a000)
	libnsl.so.1 => /lib64/libnsl.so.1 (0x00007fda3f530000)
	libselinux.so.1 => /lib64/libselinux.so.1 (0x00007fda3f312000)

steved.
