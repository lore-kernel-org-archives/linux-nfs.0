Date: Wed, 18 Feb 2015 14:28:36 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfs4 state manager loop on recallable state revoked
In-Reply-To: <CAHQdGtQaj99Sy0qOUky2uE7XX0UXbJOC8LXNvDANzbc1Adio7A@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1502181212250.80359@planck.local>
References: <alpine.OSX.2.19.9992.1502180937030.80359@planck.local> <CAHQdGtQaj99Sy0qOUky2uE7XX0UXbJOC8LXNvDANzbc1Adio7A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="0-844536861-1424287717=:80359"
List-ID: <linux-nfs.vger.kernel.org>

--0-844536861-1424287717=:80359
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Wed, 18 Feb 2015, Trond Myklebust wrote:
> On Wed, Feb 18, 2015 at 8:22 AM, Benjamin Coddington
> <bcodding@redhat.com> wrote:
> > While playing with callback channel failures, I noticed the state manager
> > get stuck looping trying to check a lease when the server responds with
> > SEQ4_STATUS_RECALLABLE_STATE_REVOKED set.
> >
> > Does this look familiar to anyone?
> >
> > [67732.348087] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
> > [67732.369726] nfs4_free_slot: slotid 2 highest_used_slotid 1
> > [67732.372881] nfs4_free_slot: slotid 0 highest_used_slotid 1
> > [67732.375337] nfs4_schedule_state_renewal: requeueing work. Lease period = 5
> > [67732.394736] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
> > [67732.401010] nfs4_free_slot: slotid 0 highest_used_slotid 1
> > [67732.402910] nfs4_free_slot: slotid 1 highest_used_slotid 4294967295
> > [67732.404659] nfs4_schedule_stateid_recovery: scheduling stateid recovery for server fedora
> > [67732.422848] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
> > [67732.426257] nfs4_free_slot: slotid 1 highest_used_slotid 0
> > [67732.427250] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> > [67732.428291] nfs41_handle_sequence_flag_errors: "fedora" (client ID f49be45401000000) flags=0x00000041
> > [67732.429596] nfs41_handle_recallable_state_revoked: Recallable state revoked on server fedora!
> > [67732.430746] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
> > [67732.431817] nfs4_recovery_handle_error: handled error 0 for server fedora
> > [67732.439132] nfs4_bind_conn_to_session: bind_conn_to_session was successful for server fedora!
> > [67732.451098] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
> > [67732.454522] nfs4_free_slot: slotid 1 highest_used_slotid 0
> > [67732.455557] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> > [67732.456647] nfs41_handle_sequence_flag_errors: "fedora" (client ID f49be45401000000) flags=0x00000040
> > [67732.457986] nfs41_handle_recallable_state_revoked: Recallable state revoked on server fedora!
> > [67732.459215] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
> > [67732.460350] nfs4_recovery_handle_error: handled error 0 for server fedora
> > [67732.472138] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
> > [67732.475707] nfs4_free_slot: slotid 1 highest_used_slotid 0
> > [67732.476779] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> > [67732.477917] nfs41_handle_sequence_flag_errors: "fedora" (client ID f49be45401000000) flags=0x00000040
> > [67732.479294] nfs41_handle_recallable_state_revoked: Recallable state revoked on server fedora!
> > [67732.480572] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
> > [67732.481753] nfs4_recovery_handle_error: handled error 0 for server fedora
> > [67732.493666] nfs4_schedule_lease_recovery: scheduling lease recovery for server fedora
> > [67732.497269] nfs4_free_slot: slotid 1 highest_used_slotid 0
> > [67732.498402] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> > [67732.499563] nfs41_handle_sequence_flag_errors: "fedora" (client ID f49be45401000000) flags=0x00000040
> > [67732.500894] nfs41_handle_recallable_state_revoked: Recallable state revoked on server fedora!
> > [67732.502159] nfs4_schedule_state_renewal: requeueing work. Lease period = 60
> >
> > I think what's happening is that we never get to reclaim_lease() because
> > NFS4CLNT_LEASE_EXPIRED is never flagged.  Should we set
> > NFS4CLNT_LEASE_EXPIRED in nfs41_handle_cb_path_down()?  I think that would
> > have avoided this.
>
> I don't understand Why would the server reply NFS4ERR_OK to the
> sequence operation if the lease has expired?
> Right now, we assume that the server is doing the right thing w.r.t.
> the lease, so instead, we call BIND_CONN_TO_SESSION with a request
> that the fore and back channel be associated to this TCP connection.

I may have oversimplified.. let me see if I can explain.

There's netfilter rules using ESTABLISHED,RELATED on the client, and I've
tuned down nf_conntrack's established and time_wait timeouts to 10 seconds.

echo 10 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_established
echo 10 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_time_wait

That causes netfilter to prune the connection tracking so that callbacks
fail if the client has been idle for 10 seconds or more.  It also means that
as soon as the client transmits, the callback channel is "repaired".

So the client gets a delegation, and after 10 seconds the server tries to
call it back (because I wrote to the file), only to find the callback channel
is down.

Then, the client tries to renew the lease, and a retransmit of the callback
makes it through, but this is after the server has decided the callback
channel is down.  This is the point where I get lost in the state manager
code.

I think that the client tries to recover the delegation, gets BAD_STATEID,
which should cause us to reclaim open state, eventually leading to freeing
of the stateid.. but that doesn't happen.  I think because
NFS4CLNT_CHECK_LEASE is already set without NFS4CLNT_LEASE_EXPIRED, so we
cannot get to nfs4_do_reclaim().  Since the server never gets a
FREE_STATEID, it will always set SEQ4_STATUS_RECALLABLE_STATE_REVOKED.

Here's the network cap overview.. let me know if you'd like the whole thing.
The interesting bit is around frame 193.

156 137.857403000    10.0.1.82 -> 10.0.1.85    NFS 278 V4 Reply (Call In 153) EXCHANGE_ID
157 137.857506000    10.0.1.85 -> 10.0.1.82    TCP 66 895→2049 [ACK] Seq=405 Ack=241 Win=30336 Len=0 TSval=67302510 TSecr=11923
158 137.858980000    10.0.1.85 -> 10.0.1.82    NFS 338 V4 Call CREATE_SESSION
159 137.864535000    10.0.1.82 -> 10.0.1.85    NFS 150 V1 CB_NULL Call
160 137.864628000    10.0.1.85 -> 10.0.1.82    NFS 94 V1 CB_NULL Reply (Call In 159)
161 137.867513000    10.0.1.82 -> 10.0.1.85    NFS 262 V4 Reply (Call In 158) CREATE_SESSION
162 137.879044000    10.0.1.85 -> 10.0.1.82    NFS 262 V4 Call RECLAIM_COMPLETE
163 137.904896000    10.0.1.82 -> 10.0.1.85    NFS 226 V4 Reply (Call In 162) RECLAIM_COMPLETE
164 137.912835000    10.0.1.85 -> 10.0.1.82    NFS 222 V4 Call PUTROOTFH | GETATTR
165 137.927247000    10.0.1.82 -> 10.0.1.85    NFS 322 V4 Reply (Call In 164) PUTROOTFH | GETATTR
166 137.933836000    10.0.1.85 -> 10.0.1.82    NFS 226 V4 Call GETATTR FH: 0x62d40c52
167 137.945763000    10.0.1.82 -> 10.0.1.85    NFS 210 V4 Reply (Call In 166) GETATTR
168 137.952221000    10.0.1.85 -> 10.0.1.82    NFS 230 V4 Call GETATTR FH: 0x62d40c52
169 137.964209000    10.0.1.82 -> 10.0.1.85    NFS 222 V4 Reply (Call In 168) GETATTR
170 137.970844000    10.0.1.85 -> 10.0.1.82    NFS 226 V4 Call GETATTR FH: 0x62d40c52
171 137.982775000    10.0.1.82 -> 10.0.1.85    NFS 210 V4 Reply (Call In 170) GETATTR
172 137.989276000    10.0.1.85 -> 10.0.1.82    NFS 230 V4 Call GETATTR FH: 0x62d40c52
173 138.001042000    10.0.1.82 -> 10.0.1.85    NFS 222 V4 Reply (Call In 172) GETATTR
174 138.007406000    10.0.1.85 -> 10.0.1.82    NFS 226 V4 Call GETATTR FH: 0x62d40c52
175 138.019286000    10.0.1.82 -> 10.0.1.85    NFS 186 V4 Reply (Call In 174) GETATTR
176 138.025406000    10.0.1.85 -> 10.0.1.82    NFS 226 V4 Call GETATTR FH: 0x62d40c52
177 138.037430000    10.0.1.82 -> 10.0.1.85    NFS 210 V4 Reply (Call In 176) GETATTR
178 138.043344000    10.0.1.85 -> 10.0.1.82    NFS 234 V4 Call GETATTR FH: 0x62d40c52
179 138.055168000    10.0.1.82 -> 10.0.1.85    NFS 354 V4 Reply (Call In 178) GETATTR
180 138.061072000    10.0.1.85 -> 10.0.1.82    NFS 238 V4 Call ACCESS FH: 0x62d40c52, [Check: RD LU MD XT DL]
181 138.074921000    10.0.1.82 -> 10.0.1.85    NFS 238 V4 Reply (Call In 180) ACCESS, [Access Denied: MD XT DL], [Allowed: RD LU]
182 138.084987000    10.0.1.85 -> 10.0.1.82    NFS 230 V4 Call GETATTR FH: 0x62d40c52
183 138.098533000    10.0.1.82 -> 10.0.1.85    NFS 230 V4 Reply (Call In 182) GETATTR
184 138.105253000    10.0.1.85 -> 10.0.1.82    NFS 242 V4 Call ACCESS FH: 0x62d40c52, [Check: RD LU MD XT DL]
185 138.119543000    10.0.1.82 -> 10.0.1.85    NFS 238 V4 Reply (Call In 184) ACCESS, [Access Denied: MD XT DL], [Allowed: RD LU]
186 138.125581000    10.0.1.85 -> 10.0.1.82    NFS 258 V4 Call LOOKUP DH: 0x62d40c52/bcodding
187 138.142873000    10.0.1.82 -> 10.0.1.85    NFS 406 V4 Reply (Call In 186) LOOKUP
188 138.148820000    10.0.1.85 -> 10.0.1.82    NFS 250 V4 Call ACCESS FH: 0x5a3a896a, [Check: RD LU MD XT DL]
189 138.162711000    10.0.1.82 -> 10.0.1.85    NFS 238 V4 Reply (Call In 188) ACCESS, [Allowed: RD LU MD XT DL]
190 138.168768000    10.0.1.85 -> 10.0.1.82    NFS 326 V4 Call OPEN DH: 0x5a3a896a/foo
191 138.190654000    10.0.1.82 -> 10.0.1.85    NFS 514 V4 Reply (Call In 190) OPEN StateID: 0xf6b5
192 138.230847000    10.0.1.85 -> 10.0.1.82    TCP 66 895→2049 [ACK] Seq=3341 Ack=3557 Win=46464 Len=0 TSval=67302883 TSecr=12256
193 159.403954000    10.0.1.82 -> 10.0.1.85    NFS 250 V1 CB_COMPOUND Call <EMPTY> CB_SEQUENCE;CB_RECALL
194 159.404102000    10.0.1.85 -> 10.0.1.82    ICMP 278 Destination unreachable (Host administratively prohibited)
195 159.615010000    10.0.1.82 -> 10.0.1.85    NFS 250 [RPC retransmission of #193][TCP Retransmission] V1 CB_COMPOUND Call <EMPTY> CB_SEQUENCE;CB_RECALL
196 159.615217000    10.0.1.85 -> 10.0.1.82    ICMP 278 Destination unreachable (Host administratively prohibited)
197 159.826080000    10.0.1.82 -> 10.0.1.85    NFS 250 [RPC retransmission of #193][TCP Retransmission] V1 CB_COMPOUND Call <EMPTY> CB_SEQUENCE;CB_RECALL
198 159.826285000    10.0.1.85 -> 10.0.1.82    ICMP 278 Destination unreachable (Host administratively prohibited)
199 160.249069000    10.0.1.82 -> 10.0.1.85    NFS 250 [RPC retransmission of #193][TCP Retransmission] V1 CB_COMPOUND Call <EMPTY> CB_SEQUENCE;CB_RECALL
200 160.249304000    10.0.1.85 -> 10.0.1.82    ICMP 278 Destination unreachable (Host administratively prohibited)
201 161.094138000    10.0.1.82 -> 10.0.1.85    NFS 250 [RPC retransmission of #193][TCP Retransmission] V1 CB_COMPOUND Call <EMPTY> CB_SEQUENCE;CB_RECALL
202 161.094655000    10.0.1.85 -> 10.0.1.82    ICMP 278 Destination unreachable (Host administratively prohibited)
203 162.786081000    10.0.1.82 -> 10.0.1.85    NFS 250 [RPC retransmission of #193][TCP Retransmission] V1 CB_COMPOUND Call <EMPTY> CB_SEQUENCE;CB_RECALL
204 162.786329000    10.0.1.85 -> 10.0.1.82    ICMP 278 Destination unreachable (Host administratively prohibited)
205 166.174148000    10.0.1.82 -> 10.0.1.85    NFS 250 [RPC retransmission of #193][TCP Retransmission] V1 CB_COMPOUND Call <EMPTY> CB_SEQUENCE;CB_RECALL
206 166.174679000    10.0.1.85 -> 10.0.1.82    ICMP 278 Destination unreachable (Host administratively prohibited)
207 172.942070000    10.0.1.82 -> 10.0.1.85    NFS 250 [RPC retransmission of #193][TCP Retransmission] V1 CB_COMPOUND Call <EMPTY> CB_SEQUENCE;CB_RECALL
208 172.942310000    10.0.1.85 -> 10.0.1.82    ICMP 278 Destination unreachable (Host administratively prohibited)
209 186.478053000    10.0.1.82 -> 10.0.1.85    NFS 250 [RPC retransmission of #193][TCP Retransmission] V1 CB_COMPOUND Call <EMPTY> CB_SEQUENCE;CB_RECALL
210 186.478341000    10.0.1.85 -> 10.0.1.82    ICMP 278 Destination unreachable (Host administratively prohibited)
211 198.221376000    10.0.1.85 -> 10.0.1.82    TCP 66 [TCP Keep-Alive] 895→2049 [ACK] Seq=3340 Ack=3557 Win=46464 Len=0 TSval=67362844 TSecr=12256
212 198.221443000    10.0.1.82 -> 10.0.1.85    TCP 66 [TCP Keep-Alive ACK] 2049→895 [ACK] Seq=3741 Ack=3341 Win=47232 Len=0 TSval=72287 TSecr=67302883
213 198.341623000    10.0.1.85 -> 10.0.1.82    NFS 254 V4 Call SEQUENCE
214 198.381099000    10.0.1.82 -> 10.0.1.85    TCP 66 2049→895 [ACK] Seq=3741 Ack=3529 Win=48256 Len=0 TSval=72447 TSecr=67362964
215 213.550073000    10.0.1.82 -> 10.0.1.85    NFS 250 [RPC retransmission of #193][TCP Retransmission] V1 CB_COMPOUND Call <EMPTY> CB_SEQUENCE;CB_RECALL
216 213.550305000    10.0.1.85 -> 10.0.1.82    ICMP 278 Destination unreachable (Host administratively prohibited)
217 258.410816000    10.0.1.85 -> 10.0.1.82    TCP 66 [TCP Keep-Alive] 895→2049 [ACK] Seq=3528 Ack=3557 Win=46464 Len=0 TSval=67423004 TSecr=12256
218 258.410899000    10.0.1.82 -> 10.0.1.85    TCP 66 [TCP Keep-Alive ACK] 2049→895 [ACK] Seq=3741 Ack=3529 Win=48256 Len=0 TSval=132476 TSecr=67362964
219 263.422122000 RealtekU_30:a6:48 -> RealtekU_f2:45:f7 ARP 42 Who has 10.0.1.85?  Tell 10.0.1.82
220 263.422560000 RealtekU_f2:45:f7 -> RealtekU_30:a6:48 ARP 42 10.0.1.85 is at 52:54:00:f2:45:f7
221 267.758096000    10.0.1.82 -> 10.0.1.85    NFS 250 [RPC retransmission of #193][TCP Retransmission] V1 CB_COMPOUND Call <EMPTY> CB_SEQUENCE;CB_RECALL
222 267.758576000    10.0.1.85 -> 10.0.1.82    TCP 66 895→2049 [ACK] Seq=3529 Ack=3741 Win=47488 Len=0 TSval=67432347 TSecr=141824
223 267.758646000    10.0.1.82 -> 10.0.1.85    NFS 218 V4 Reply (Call In 213) SEQUENCE
224 267.758740000    10.0.1.85 -> 10.0.1.82    NFS 154 V1 CB_COMPOUND Reply (Call In 193) <EMPTY> CB_SEQUENCE;CB_RECALL
225 267.758762000    10.0.1.82 -> 10.0.1.85    TCP 66 2049→895 [ACK] Seq=3893 Ack=3617 Win=48256 Len=0 TSval=141824 TSecr=67432347
226 267.774018000    10.0.1.85 -> 10.0.1.82    NFS 322 V4 Call OPEN DH: 0x2aa3b5f8/
227 267.774075000    10.0.1.82 -> 10.0.1.85    TCP 66 2049→895 [ACK] Seq=3893 Ack=3873 Win=49408 Len=0 TSval=141840 TSecr=67432361
228 267.805457000    10.0.1.82 -> 10.0.1.85    NFS 166 V4 Reply (Call In 226) OPEN Status: NFS4ERR_BAD_STATEID
229 267.821189000    10.0.1.85 -> 10.0.1.82    NFS 254 V4 Call SEQUENCE
230 267.833606000    10.0.1.82 -> 10.0.1.85    NFS 218 V4 Reply (Call In 229) SEQUENCE
231 267.844159000    10.0.1.85 -> 10.0.1.82    NFS 246 V4 Call BIND_CONN_TO_SESSION
232 267.846580000    10.0.1.82 -> 10.0.1.85    NFS 150 V1 CB_NULL Call
233 267.848899000    10.0.1.85 -> 10.0.1.82    NFS 94 V1 CB_NULL Reply (Call In 232)
234 267.849888000    10.0.1.82 -> 10.0.1.85    NFS 206 V4 Reply (Call In 231) BIND_CONN_TO_SESSION
235 267.853635000    10.0.1.85 -> 10.0.1.82    NFS 254 V4 Call SEQUENCE
236 267.861895000    10.0.1.82 -> 10.0.1.85    NFS 218 V4 Reply (Call In 235) SEQUENCE
237 267.874848000    10.0.1.85 -> 10.0.1.82    NFS 254 V4 Call SEQUENCE
238 267.882922000    10.0.1.82 -> 10.0.1.85    NFS 218 V4 Reply (Call In 237) SEQUENCE
239 267.896322000    10.0.1.85 -> 10.0.1.82    NFS 254 V4 Call SEQUENCE
240 267.904455000    10.0.1.82 -> 10.0.1.85    NFS 218 V4 Reply (Call In 239) SEQUENCE
241 267.918109000    10.0.1.85 -> 10.0.1.82    NFS 254 V4 Call SEQUENCE
242 267.926220000    10.0.1.82 -> 10.0.1.85    NFS 218 V4 Reply (Call In 241) SEQUENCE
243 267.940334000    10.0.1.85 -> 10.0.1.82    NFS 254 V4 Call SEQUENCE
244 267.948684000    10.0.1.82 -> 10.0.1.85    NFS 218 V4 Reply (Call In 243) SEQUENCE
245 267.962701000    10.0.1.85 -> 10.0.1.82    NFS 254 V4 Call SEQUENCE
246 267.970790000    10.0.1.82 -> 10.0.1.85    NFS 218 V4 Reply (Call In 245) SEQUENCE
247 267.984855000    10.0.1.85 -> 10.0.1.82    NFS 254 V4 Call SEQUENCE
248 267.992957000    10.0.1.82 -> 10.0.1.85    NFS 218 V4 Reply (Call In 247) SEQUENCE
249 268.006746000    10.0.1.85 -> 10.0.1.82    NFS 254 V4 Call SEQUENCE
250 268.014828000    10.0.1.82 -> 10.0.1.85    NFS 218 V4 Reply (Call In 249) SEQUENCE
251 268.028895000    10.0.1.85 -> 10.0.1.82    NFS 254 V4 Call SEQUENCE
252 268.037021000    10.0.1.82 -> 10.0.1.85    NFS 218 V4 Reply (Call In 251) SEQUENCE
253 268.052380000    10.0.1.85 -> 10.0.1.82    NFS 254 V4 Call SEQUENCE
254 268.060971000    10.0.1.82 -> 10.0.1.85    NFS 218 V4 Reply (Call In 253) SEQUENCE
...

Ben
--0-844536861-1424287717=:80359--
