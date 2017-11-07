Return-Path: <aweits@rit.edu>
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: bcodding redhat <bcodding@redhat.com>,
  "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
  "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v8 00/11] Fix OPEN/CLOSE races
References: <20171106202811.70202-1-trond.myklebust@primarydata.com>
	<m2vainowk1.fsf@discipline.rit.edu>
	<1510008607.3861.1.camel@primarydata.com>
Date: Tue, 07 Nov 2017 11:59:27 -0500
In-Reply-To: <1510008607.3861.1.camel@primarydata.com> (Trond Myklebust's
	message of "Mon, 6 Nov 2017 22:50:09 +0000")
Message-ID: <m2y3ninhxs.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <trondmy@primarydata.com> writes:

> On Mon, 2017-11-06 at 17:46 -0500, Andrew W Elble wrote:
>> Trond Myklebust <trond.myklebust@primarydata.com> writes:
>> 
>> > v8:
>> > - Really fix compile issue when CONFIG_NFS_V4_1=n
>> > - nfs_inode_find_state_and_recover() should also try to match the
>> >   open_stateid.
>> 
>> Seeing a lot of TEST_STATEID's for the invalid stateid go over the
>> wire - this also makes the server hit this quite a bit:
>> 
>> pr_warn_ratelimited("NFSD: client %s testing state ID "
>>                         "with incorrect client ID\n", addr_str);
>> 
>
> I'm not seeing that at all. Can you please elaborate on which server
> errors are triggering this? I'd not expect to ever see TEST_STATEID on
> a normal run.

Hopefully this helps.

Not completely sure this is correct, but this makes the client no longer
test the _invalid_ stateid:

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6eccbd1b98cc..7dc914a6356f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1436,6 +1436,8 @@ static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
                nfs_resync_open_stateid_locked(state);
                goto out;
        }
+       if (test_bit(NFS_OPEN_STATE, &state->flags) == 0)
+               stateid->type = NFS4_INVALID_STATEID_TYPE;
        if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
                nfs4_stateid_copy(&state->stateid, stateid);
        nfs4_stateid_copy(&state->open_stateid, stateid);


The TEST_STATEID's are being issued from the "freeme" path of
update_open_stateid() via nfs4_opendata_to_nfs4_state(). I put a tracepoint
there:

@@ -1597,10 +1599,11 @@ static int update_open_stateid(struct nfs4_state *state,
 
 	if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags))
 		nfs4_schedule_state_manager(clp);
-	if (freeme.type != 0)
+	if (freeme.type != 0) {
 		nfs4_test_and_free_stateid(server, &freeme,
 				state->owner->so_cred);
-
+		trace_nfs4_test_and_free_stateid(state->inode, &freeme, 0);
+	}
 	return ret;
 }


Even with the topmost patch in place, TEST_STATEID's still do occur with non-invalid stateids.
Here is some trace data of a stateid that had such an event:

       blogbench-2271  [001] ....    24.776203: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=1:0x65b62c64
       blogbench-2271  [001] ....    24.776233: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=1:0x65b62c64 openstateid=1:0x65b62c64
       blogbench-2198  [002] .N..    24.777914: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=2:0x65b62c64
       blogbench-2198  [002] ....    24.778016: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=2:0x65b62c64 openstateid=2:0x65b62c64
     kworker/0:3-587   [000] ....    24.778132: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=1:0x65b62c64
     kworker/1:2-113   [001] ....    24.779489: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=2:0x65b62c64
     kworker/2:2-330   [002] ....    24.779516: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=2:0x65b62c64
     kworker/0:3-587   [000] ....    24.779730: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=2:0x65b62c64
     kworker/3:2-165   [003] ....    24.779763: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=2:0x65b62c64
     kworker/2:2-330   [002] ....    24.779862: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=2:0x65b62c64
     kworker/1:2-113   [001] ....    24.779991: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=2:0x65b62c64
     kworker/0:3-587   [000] ....    24.780049: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=2:0x65b62c64
       blogbench-2254  [003] ....    24.780421: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=3:0x65b62c64
       blogbench-2254  [003] ....    24.780425: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=3:0x65b62c64 openstateid=3:0x65b62c64
       blogbench-2195  [003] ....    24.780473: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=4:0x65b62c64
       blogbench-2195  [003] ....    24.780478: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=4:0x65b62c64 openstateid=4:0x65b62c64
       blogbench-2219  [003] ....    24.780576: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=5:0x65b62c64
       blogbench-2219  [003] ....    24.780581: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=5:0x65b62c64 openstateid=5:0x65b62c64
       blogbench-2223  [003] ....    24.780608: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=6:0x65b62c64
       blogbench-2223  [003] ....    24.780612: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=6:0x65b62c64 openstateid=6:0x65b62c64
       blogbench-2256  [003] ....    24.780637: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=7:0x65b62c64
       blogbench-2256  [003] ....    24.780642: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=7:0x65b62c64 openstateid=7:0x65b62c64
       blogbench-2206  [003] ....    24.780676: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=8:0x65b62c64
       blogbench-2206  [003] ....    24.780680: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=8:0x65b62c64 openstateid=8:0x65b62c64
     kworker/0:3-587   [000] ....    24.780698: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=2:0x65b62c64
       blogbench-2211  [003] ....    24.780716: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=9:0x65b62c64
       blogbench-2211  [003] ....    24.780721: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=9:0x65b62c64 openstateid=9:0x65b62c64
       blogbench-2242  [003] ....    24.780753: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=10:0x65b62c64
       blogbench-2242  [003] ....    24.780758: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=10:0x65b62c64 openstateid=10:0x65b62c64
       blogbench-2253  [003] ....    24.780789: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=11:0x65b62c64
       blogbench-2253  [003] ....    24.780794: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=11:0x65b62c64 openstateid=11:0x65b62c64
       blogbench-2262  [003] ....    24.780857: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=12:0x65b62c64
       blogbench-2262  [003] ....    24.780862: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=12:0x65b62c64 openstateid=12:0x65b62c64
       blogbench-2281  [003] ....    24.780894: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=13:0x65b62c64
       blogbench-2281  [003] ....    24.780899: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=13:0x65b62c64 openstateid=13:0x65b62c64
       blogbench-2287  [003] ....    24.780930: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=14:0x65b62c64
       blogbench-2287  [003] ....    24.780935: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=14:0x65b62c64 openstateid=14:0x65b62c64
     kworker/1:2-113   [001] ....    24.780944: nfs4_close: error=-10024 (OLD_STATEID) fmode=READ fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=4:0x65b62c64
       blogbench-2291  [003] ....    24.780975: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=15:0x65b62c64
       blogbench-2291  [003] ....    24.780979: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:73739313 fhandle=0x8bf9d249 name=00:2e:70677670/article-6.xml stateid=15:0x65b62c64 openstateid=15:0x65b62c64
     kworker/0:3-587   [000] ....    24.780989: nfs4_close: error=-10024 (OLD_STATEID) fmode=READ fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=2:0x65b62c64
     kworker/0:3-587   [000] ....    24.781122: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=3:0x65b62c64
     kworker/2:2-330   [002] ....    24.781250: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=5:0x65b62c64
     kworker/2:2-330   [002] ....    24.781261: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=6:0x65b62c64
     kworker/2:2-330   [002] ....    24.781269: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=7:0x65b62c64
     kworker/3:2-165   [003] ....    24.781409: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=8:0x65b62c64
     kworker/3:2-165   [003] ....    24.781423: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=8:0x65b62c64
     kworker/1:2-113   [001] ....    24.781514: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=10:0x65b62c64
     kworker/1:2-113   [001] ....    24.781625: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=9:0x65b62c64
     kworker/1:2-113   [001] ....    24.781639: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=12:0x65b62c64
     kworker/3:2-165   [003] ....    24.782038: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=11:0x65b62c64
     kworker/1:2-113   [001] ....    24.782054: nfs4_close: error=-10025 (BAD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=15:0x65b62c64
     kworker/3:2-165   [003] ....    24.782054: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=13:0x65b62c64
     kworker/3:2-165   [003] ....    24.782069: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=14:0x65b62c64
     kworker/1:2-113   [001] ....    24.782071: nfs4_close: error=-10025 (BAD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=15:0x65b62c64
     kworker/3:2-165   [003] ....    24.782082: nfs4_close: error=-10024 (OLD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=14:0x65b62c64
     kworker/3:2-165   [003] ....    24.782114: nfs4_close: error=0 (OK) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=15:0x65b62c64
     kworker/3:2-165   [003] ....    24.782128: nfs4_close: error=-10025 (BAD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=15:0x65b62c64
     kworker/2:2-330   [002] ....    24.782144: nfs4_close: error=-10025 (BAD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=15:0x65b62c64
     kworker/3:2-165   [003] ....    24.782152: nfs4_close: error=-10025 (BAD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=15:0x65b62c64
     kworker/3:2-165   [003] ....    24.782167: nfs4_close: error=-10025 (BAD_STATEID) fmode=closed fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=15:0x65b62c64
     kworker/2:2-330   [002] ....    24.782423: nfs4_close: error=-10025 (BAD_STATEID) fmode=READ fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=15:0x65b62c64
     kworker/3:2-165   [003] ....    24.782469: nfs4_close: error=-10025 (BAD_STATEID) fmode=READ fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=15:0x65b62c64
     kworker/3:2-165   [003] ....    24.782484: nfs4_close: error=-10025 (BAD_STATEID) fmode=READ fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=15:0x65b62c64
     kworker/3:2-165   [003] ....    24.782498: nfs4_close: error=-10025 (BAD_STATEID) fmode=READ fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=15:0x65b62c64
     kworker/1:2-113   [001] ....    24.782548: nfs4_close: error=-10025 (BAD_STATEID) fmode=READ fileid=00:2e:73739313 fhandle=0x8bf9d249 openstateid=15:0x65b62c64
       blogbench-2238  [001] ....    24.782669: nfs4_test_and_free_stateid: error=0 (OK) fileid=00:2e:73739313 fhandle=0x8bf9d249 stateid=15:0x65b62c64
       blogbench-2232  [002] ....    38.135974: nfs4_open_stateid_update: error=0 (OK) fileid=00:2e:210215186 fhandle=0x33c12cc7 stateid=1:0x765b624f
       blogbench-2232  [002] ....    38.135983: nfs4_open_file: error=0 (OK) flags=32768 (0x8000) fmode=READ|0x801c fileid=00:2e:210215186 fhandle=0x33c12cc7 name=00:2e:210169499/picture-37.jpg stateid=1:0x765b624f openstateid=1:0x765b624f
     kworker/1:2-113   [001] ....    38.138993: nfs4_close: error=0 (OK) fmode=closed fileid=00:2e:210215186 fhandle=0x33c12cc7 openstateid=1:0x765b624f

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
